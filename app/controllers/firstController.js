var app = angular.module('FirstModule', []);

app.controller('FirstService', ['$scope', '$http', function ($scope, $http) {

    $scope.first = 0;
    $scope.second = 0;

    $scope.addFunction = function (x, y) {
        return x + y;
    };

    $scope.mulFunction = function () {
        return $scope.first * $scope.second
    }

    $scope.callAnotherFunction = function () {
        return $scope.addFunction(10, 20);
    }

    $scope.mockAnotherFunction = function () {
        return $scope.addFunction(10, 20);
    }

    $scope.apiCallingFunction = function () {
        return $http.get('/api/users');
    }
}]);