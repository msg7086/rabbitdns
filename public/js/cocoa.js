rabbitHouse.controller('Cocoa', function ($scope, $http) {
  $scope.domains = []
  $scope.records = []
  $scope.active_domain = null
  $scope.$on('Cocoa::Shigoto', function(event, msg) {
    if(msg[0] == 'LoadDomains') $scope.domains = msg[1]
    else if(msg[0] === 'RefreshDomains') $scope.refresh_domains()
    else if(msg[0] === 'RefreshRecords') $scope.load_records($scope.active_domain)
  })
  $scope.refresh_domains = function () {
    $scope.domains = []
    $scope.records = []
    $scope.active_domain = null
    $http.get('/api/domain').success(function (data) {
      $scope.domains = data
    })
  }
  $scope.load_records = function (domain) {
    $scope.records = []
    $scope.active_domain = domain
    $http.get('/api/domain/'+domain.id).success(function (data) {
      $scope.records = data
      $scope.analyize_records()
    })
  }
  $scope.add_domain = function () {
    $scope.$emit('Call', ['Megu', 'Add'])
  }
  $scope.analyize_records = function () {
    var data = $scope.records
    var groups = {A: {}, C: {}, MX: {}, TXT: [], SRV: [], NS: [], SOA: []}
    data.forEach(function (d) {
      var type = d.type
      var key = d.content
      if (type === 'A' || type === 'AAAA') {
        groups.A[key] = groups.A[key] || []
        groups.A[key].push(d)
      } else if (type === 'CNAME') {
        groups.C[key] = groups.C[key] || []
        groups.C[key].push(d)
      } else if (type === 'MX') {
        key = d.name
        groups.MX[key] = groups.MX[key] || []
        groups.MX[key].push(d)
      } else {
        groups[d.type] = groups[d.type] || []
        groups[d.type].push(d)
      }
    })
    $scope.groups = groups
  }
  $scope.edit = function (r) {
    $scope.$emit('Call', ['Maya', 'Edit', $scope.active_domain, r])
  }
  $scope.append = function (r, skip) {
    $scope.$emit('Call', ['Maya', 'Append', $scope.active_domain, r, skip])
  }
  $scope.add = function (type) {
    $scope.$emit('Call', ['Maya', 'Add', $scope.active_domain, type])
  }
  $scope.prefix = function (name) {
    var p = name.slice(0, -$scope.active_domain.name.length - 1)
    return p.length == 0 ? '@' : p
  }
})
