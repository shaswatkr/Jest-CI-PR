# Jest Unit Testing & Code Coverage With AngularJS
The project give us a walkthrough as how to use `jest-cli` for Unit Testing & getting Code Coverage of `AngularJS 1.6.10`.
Further AngularJS is compiled and run using `gulp`

This project was bootstrapped with [AngularJS](https://angularjs.org) version 1.6.10.

- [firstController.js](/app/controllers/firstController.js) is a simple AngularJS module & controller with 3 functions, which we're Unit Testing in the next test class.
- [firstController.test.js](/tests/firstController.test.js) contains all the function to test the module it's pointing to.

## Need for the project
-   The famous `jest` library for Testing AngularJS project is not properly documented and one need multpile stackoverflow sites, other websites, to even understand how to start with the integration.

So this project consist of how to add the library into your project and then a working model of how to start implementing it's functionality for Unit Testing, Mocking of $scope data, API call return, functions & Code Coverage Report Generation in your AngularJS project. Now anyone can refer this project and get a know-how of the codes required to integrate and implement testing they need for their project.

# Description
For any project, unit Testing is the most crucial part. It keeps code quality in line and helps developers by providing infomation if any of his/her changes has not broken the already existing code. It's kind of an early-warning system, which alert Devs of any functionality break as soon as he make his changes. This helps team as less and less Defect need to be created.

Also Code Coverage which tells us about Line of code which is being tested helps DEV and team alike in maintaining that all the functionality are being tested, all IF-ELSE, function call, etc are being covered. In sense giving DEV with info as what else he should write Unit Test about.

```
In file firstController.js we've 5 functions each with different testing conditions:
addFunction() -> Gets x & y in function call and add them up - We're passing the values during testing,
mulFunction() -> Uses 2 $scope var to multiple them - We're mocking those 2 $scope var,
callAnotherFunction() -> Calls another internal function - We're checking if we can call a function without mocking,
mockAnotherFunction() -> Calls another function - We're mocking the internal function being called so to override the actual function during testing,
apiCallingFunction() -> Calls an API to return data - We're mocking API return so we'll get data directly from promise instead of actual backend call
```

#### Properties:
- Jest automatically read all `*.test.js` files in you project and run all tes cases written inside it to give you all the info you'll need while Developing.
  - If your test function is being passed or not.
  - If not passed, then what's the problem.
  - What value it was expcting and what we got.
  - Which test function is failing and which are passing.
- Also it gives a beautiful and extensive code coverage report which can we viewed in any browser
  - It gives info like line of code covered, number of functions covered, numer of branches(IF-ELSE) covered. Both % wise and out of.
  - All this info is not only goven for entire files, but it even breaks down based on file structure and independent files. So you've all and any kind of info at your grasp.
  - Further you can open single file, which will open a visual represenation of the code with info like whichall line has been covered, numbr of times a line is being covered, lines un-covered by your test, branched uncovered, etc.

##### This is just a BoilerPlate UI. it'll juest print a white page wth text `AngularJS Boilerplate with Jest` if you run the project.

# Getting Started
## Download
```
git clone https://github.optum.com/skuma874/JestWithAngularJS
```

## Installation Of Packages (To be done in the folder containing your project)
```
- npm install angular-mocks --save-dev
- npm install jest-cli --save-dev
```

## Adding Jest script into your package.json
Search `scripts` and add:
```
"test": "jest --coverage && start tests/coverage/lcov-report/index.html",
```

- jest --coverage: This command runs jest to run Unit Test along with Code Coverage on all files with `*.test.js` extension.
- start tests/coverage/lcov-report/index.html: Once Jest is successful, it opens the index.html file present in this directory mentioned. This file will display the code coverage in a beautiful webpage on your default browser.

## Adding Jest Conditions into your package.json
Now define a jest object in your package.json, for further jest conditions you want in your project:
- Suppose you want to exclude some files from Code Coverage run, just define all those files’ relative URL into coveragePathIgnorePatterns object.
- If you want to define the location where all code coverage related information is stored for display in your browser, add coverageDirectory object.
Example:
```
"jest": {
    "coveragePathIgnorePatterns": [
            "app/core/lib/angular/angular-mocks.js",
            "app/core/lib/angular/angular.min.js",
            "app/core/js/ng-table.src.js",
        "app/core/services/core/crud.js",
            "app/core/services/core/crudRouteProvider.js",
            "app/core/lib/angular/angular-route.js"
    ],
    "coverageDirectory": "<rootDir>/tests/coverage"
}
```

## Create Components
1) Create a `controller` folder in app folder where you'll create all the modules required for your project.
2) Create a `tests` folder in root directory which will keep all files required for testing and also the code coverage report.

## Starting with Unit Testing
1. Require the files needed for the test. This includes the AngularJS framework, Angular Mocks, and the actual controller we’re testing, for our example we’re testing specialinstruction-list.js.

2. Add all the other dependencies your module will require to work, example we need 'services.crud', 'ngTable'.

3. Create a describe function which will group our tests together in the same block. In this instance the block is for testing the Special Instruction List controller.

4. Mock the AngularJS module and inject the service. This will load the module and service so that we are able to reference the service to call the function.

5. Create a nested describe function which will define the constructor and mock API calls and functions.

6. Initialize all the variables which we need to pass to the controller during its initialization.  We also need to mock all APIs call as we won’t be running Node or Java code for backend.

7. Initialize the controller with all the variables so that we can use them in our Test functions.

8. Set up several tests to ensure we receive the expected output from the function. Individual tests are set up by calling the it functions. Each it then calls the function() we need to test and compares the actual result with the expected result by calling expect.

9. Run npm test and your Unit Test should start running.

10. Once all the Unit Test has passed successfully, a code coverage webpage will open which will show all the files you’ve tested, what is the LoC covered, functions called, etc.

## Sample Images of the Components

### Terminal
![Terminal](/assets/terminal.PNG)

### Browser
#### All Files which are tested
![All Files](/assets/browser1.PNG)

#### Each files seperately
![Each File](/assets/browser2.PNG)

## 1. Setup
```
npm install
```
- install all npm dependencies

**Note:** If `npm install` fails during dependency installation it will be likely caused by `gulp-imagemin`. In that case remove `gulp-imagemin` dependency from `package.json`, run `npm install` again and then install `gulp-imagemin` separately with following command: `npm install gulp-imagemin --save-dev`

## 2. Watch files
```
npm start
```

## 3. Run Unit Test & Code Coverage
```
npm test
```

## 4. Build production version
```
npm run build
```

# Maintainers (Authors)

Shaswat Kumar (shaswat_kumar87@optum.com)

# Contributing Guidelines

Please refer to [Contribution Guidelines](/CONTRIBUTING.md) for guidance on contributing to this project. There is also a [pull request template](/PULL_REQUEST_TEMPLATE) in this repo for guiding contributors through the pull request process.

