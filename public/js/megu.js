rabbitHouse.controller('Megu', function ($scope, $http) {
  $scope.domain = ''
  $scope.vcode = ''
  $scope.error = []
  $scope.$on('Megu::Shigoto', function(event, msg) {
    $scope.domain = ''
    $scope.vcode = ''
    $scope.error = []
    $('#domain').modal()
  })
  $scope.submit = function () {
    $scope.error = []
    $http.post('/api/domain', {domain: $scope.domain, vcode: $scope.vcode}
      ).success(function () {
        $('#domain').modal('hide')
        $scope.$emit('Call', ['Cocoa','RefreshDomains'])
      }).error(function (data, status) {
        if(data.error) {
          $scope.error = data.error
        } else
          alert(data)
      })
  }
})
