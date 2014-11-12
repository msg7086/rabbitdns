module RabbitHouse
  class DomainAPI < Grape::API
    helpers do
      def generate_verification_code s
        salt = $config['domain_auth_key']
        Digest::SHA2.hexdigest "#{@salt}#{s}#{@salt}"
      end
      def fetch_domain_data domain
        d = $redis.get domain
        return JSON.parse(d) if d
        who = Whois::Client.new(:referral => false)
        w1 = who.lookup(domain)
        who = Whois::Client.new(:timeout => 2)
        w2 = who.lookup(domain).technical_contact rescue nil
        d = [w1.registered?, w1.nameservers, w2]
        $redis.setex domain, 300, d.to_json # Anti-flood
        d
      end
      def send_mail domain, address
        d = $redis.get "#{domain} #{address}"
        return if d
        vcode = generate_verification_code domain
        puts "<#{address}><#{vcode}>"
        begin
          RestClient.post "https://api:#{$config['mailgun_key']}"\
            "@api.mailgun.net/v2/usagi.in/messages",
            :from => "Domain Verification <domain-verification-noreply@usagi.in>",
            :to => address,
            :subject => "Domain Verification of #{domain}",
            :text => "Hi,\n\nWe have received your request to set up DNS services on domain #{domain}. We require verification before you can use this service. Please paste the following verification code into the input box to verify your domain.\n\n#{vcode}\n\nAlternatively, you can point the name servers to our server to get verified automatically. \n\nIf you did not make such request, please ignore this mail. Thank you. \n\nRabbit House DNS Service"
        rescue => e
          puts e.response
        end
        $redis.setex "#{domain} #{address}", 600, vcode # Anti-flood
      end
      def create_domain domain
        d = current_user.domains.create name: domain, type: 'NATIVE'
        d.create_name_servers
      end
    end
    resource :domain do
      before_validation do
        authenticate!
      end
      # GET /domain
      get do
        # list domains under account
        current_user.domains.select [:id, :name]
      end

      params do
        requires :domain, type: String, desc: 'Domain name', regexp: /\A[a-zA-Z0-9\-\.]+\.[a-zA-Z]+\z/
        optional :vcode, type: String, desc: 'Optional verification code'
      end
      post do
        # create new domain
        domain = params[:domain].downcase
        error! ['Domain already exists'], 409 if Domain.find_by_name(domain)

        # vcode?
        vcode = params[:vcode]
        if vcode && generate_verification_code(domain) == vcode
          create_domain domain
          return
        end
        d = fetch_domain_data domain
        if !d[0]
          # Unable to find a domain
          error! ['Invalid domain'], 418
        end
        # compare name servers
        intersect_ns = $config['name_servers'] & d[1].map { |c| c ['name'] }
        if intersect_ns.size > 0
          create_domain domain
          return
        end
        if d[2].nil?
          # Unable to find a email
          error! ['Unable to verify due to no email address found'], 418
        end
        puts d
        email = d[2]['email']
        send_mail domain, email
        error! ["A verification email has been sent to <#{email}>"], 200
      end

      route_param :domain_id do
        before do
          begin
            @domain = Domain.find(params[:domain_id])
            if (@domain.user != current_user)
              raise ActiveRecord::RecordNotFound
            end
          rescue ActiveRecord::RecordNotFound
            error! ['Domain not exists'], 404
          end
        end
        get do
          @domain.records
        end

        post do
          if params[:id].to_i == 0
            # create
            klass = Record.types.include?(params[:type]) ? params[:type].constantize : nil
            if klass.nil?
              error! ['Unknown record type'], 400
            end
            if klass == A and params[:content].include? ?:
              params[:type] = 'AAAA'
              klass = AAAA
            end
            r = klass.new type: params[:type], domain_id: params[:domain_id]
          else
            begin
              r = Record.find params[:id]
              if (r.domain != @domain)
                raise ActiveRecord::RecordNotFound
              end
            rescue ActiveRecord::RecordNotFound
              error! ['Record not exists'], 404
            end
          end
          r.prefix = params[:name]
          r.content = params[:content]
          r.ttl = params[:ttl]
          error! r.errors.full_messages, 400 if !r.save
        end

        delete do
          begin
            r = Record.find params[:id]
            if (r.domain != @domain)
              raise ActiveRecord::RecordNotFound
            end
          rescue ActiveRecord::RecordNotFound
            error! ['Record not exists'], 404
          end
          r.destroy
          @domain.update_soa
        end

      end
    end
  end
end
