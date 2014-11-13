rabbitHouse.controller('Maya', function ($scope, $http) {
  $scope.baseuri = ''
  $scope.id = 0
  $scope.name = ''
  $scope.content = ''
  $scope.prio = 10
  $scope.ttl = 3600
  $scope.type = ''
  $scope.domain = null
  $scope.action = ''
  $scope.record = null
  $scope.error = []
  $scope.$on('Maya::Shigoto', function(event, msg) {
    $('#record').modal()
    $scope.domain = msg[1]
    $scope.baseuri = $scope.domain.name
    var record = msg[2]
    var skip = msg[3]
    $scope.record = record
    $scope.error = []
    $scope.prio = 10
    if(msg[0] === 'Edit') {
      $scope.id = record.id
      $scope.name = $scope.prefix(record.name)
      $scope.content = record.content
      $scope.ttl = record.ttl
      $scope.type = record.type
      $scope.action = 'Save'
    }
    else if(msg[0] === 'Append') {
      $scope.id = 0
      $scope.name = $scope.prefix(record.name)
      $scope.content = record.content
      $scope.ttl = record.ttl
      $scope.type = record.type
      $scope[skip] = ''
      $scope.action = 'Create'
    }
    else if(msg[0] === 'Add') {
      $scope.id = 0
      $scope.name = ''
      $scope.content = ''
      $scope.ttl = 3600
      $scope.type = msg[2]
      $scope.action = 'Create'
    }
  })
  $scope.setttl = function (newttl) {
    $scope.ttl = newttl
    return true
  }
  $scope.prefix = function (name) {
    return name.slice(0, -$scope.baseuri.length - 1)
  }
  $scope.submit = function () {
    $scope.error = []
    $http.post('/api/domain/'+$scope.domain.id,
      {id: $scope.id, name: $scope.name, content: $scope.content, type: $scope.type, ttl: $scope.ttl, prio: $scope.prio}
      ).success(function () {
        $('#record').modal('hide')
        $scope.$emit('Call', ['Cocoa','RefreshRecords'])
      }).error(function (data, status) {
        if(data.error) {
          $scope.error = data.error
        } else
          alert(data)
      })
  }
  $scope.delete = function () {
    $scope.error = []
    $http({url: '/api/domain/'+$scope.domain.id, params: {id: $scope.id}, method: 'DELETE'}
      ).success(function () {
        $('#record').modal('hide')
        $scope.$emit('Call', ['Cocoa','RefreshRecords'])
      }).error(function (data, status) {
        if(data.error) {
          $scope.error = data.error
        } else
          alert(data)
      })
  }
})
