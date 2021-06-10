require('../app/js/angular/angular.min.js');
require('../app/js/angular/angular-mocks.js');
require('../app/controllers/firstController.js');

describe('Math service', function () {

    beforeEach(
        angular.mock.module('FirstModule')
    );

    var $controller;

    beforeEach(inject(function (_$controller_) {
        $controller = _$controller_;
    }));

    describe('Test using 2 numbers', function () {

        var $scope, controller;

        beforeEach(function () {
            $scope = {};
            $http = {};
            $http.get = function (v) {
            };
            let data = ["1", "2", "3"];
            spyOn($http, "get").and.callFake(() =>
                Promise.resolve(data),
            );

            controller = $controller('FirstService', { $scope: $scope, $http: $http });
        });

        it("100 + 100 should be equal 200", function () {
            var total = $scope.addFunction(100, 100);
            expect(total).toEqual(200);
        })

        it("10 * 20 should be equal 200", function () {
            $scope.first = 10;
            $scope.second = 20;

            var total = $scope.mulFunction();
            expect(total).toEqual(200);
        });

        it("Nested function", function () {
            var total = $scope.callAnotherFunction();

            expect(total).toEqual(3);
        });

        it("Mock function", function () {
            $scope.addFunction = function () {
                return "1";
            }

            var total = $scope.mockAnotherFunction();

            expect(total).toEqual("1");
        });

        it("Mock API Call", async function () {
            var total = await $scope.apiCallingFunction();

            expect(total).toEqual(["1", "2", "3"]);
        });
    });
});

