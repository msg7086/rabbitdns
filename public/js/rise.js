rabbitHouse.controller('Rise', function ($scope, $http) {
  if(typeof(Storage) !== "undefined") {
    passkey = localStorage.passkey
  }
  if(passkey) {
    $http.defaults.headers.common['X-Key'] = passkey
    $http.get('/api/domain').success(function (data) {
      $scope.$emit('LoggedIn')
      $scope.email = $scope.password = ''
      $scope.$emit('Call', ['Cocoa', 'LoadDomains', data])
    }).error(function (data, status) {
      if(status == 401) {
        localStorage.removeItem('passkey')
      } else
        alert(data)
    })
  }
  $scope.login = function() {
    $http.post('/api/user/auth', {email: $scope.email, password: $scope.password}).success(function (passkey) {
      $http.defaults.headers.common['X-Key'] = passkey
      localStorage.passkey = passkey
      $scope.$emit('LoggedIn')
      $scope.email = $scope.password = ''
      $scope.$emit('Call', ['Cocoa', 'RefreshDomains'])
    }).error(function (data, status) {
      alert(data.error)
    })
  }
})
