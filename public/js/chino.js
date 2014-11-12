var rabbitHouse = angular.module('rabbitHouse', [])
rabbitHouse.controller('Chino', function ($scope) {
  $scope.$on('Call', function (event, msg) {
    var dare = msg.shift()
    $scope.$broadcast(dare + '::Shigoto', msg)
  })
  $scope.$on('LoggedIn', function (event, msg) {
    $scope.logged_in = true
  })
  $scope.logged_in = false
  $scope.logout = function() {
    localStorage.removeItem('passkey')
    $scope.logged_in = false
  }
})
