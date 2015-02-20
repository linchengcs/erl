(function(angular) {
  'use strict';
  angular.module('ngBlog', ['ngRoute','ngCookies'])
    .config(['$routeProvider', '$locationProvider',
             function($routeProvider, $locationProvider) {
               $routeProvider
                 .when('/Book/:bookId', {
                   templateUrl: 'book.html',
                   controller: 'BookCtrl',
                   controllerAs: 'book'
                 })
                 .when('/Book/:bookId/ch/:chapterId', {
                   templateUrl: 'chapter.html',
                   controller: 'ChapterCtrl',
                   controllerAs: 'chapter'
                 })
                 .when('/about',{
                   templateUrl: 'about.html',
                   controller: 'AboutCtrl',
                   controllerAs: 'about'
                 })
                 .when('/login',{
                   templateUrl: 'login.html',
                   controller: 'LoginCtrl',
                   controllerAs: 'login'
                 })
               ;

               $locationProvider.html5Mode(true);
             }])
    .controller('MainCtrl', ['$route', '$routeParams', '$location',
                             function($route, $routeParams, $location) {
                               this.$route = $route;
                               this.$location = $location;
                               this.$routeParams = $routeParams;
                             }])
    .controller('BookCtrl', ['$routeParams', function($routeParams) {
      this.name = "BookCtrl";
      this.params = $routeParams;
    }])
    .controller('ChapterCtrl', ['$routeParams', function($routeParams) {
      this.name = "ChapterCtrl";
      this.params = $routeParams;
    }])
    .controller('AboutCtrl', ['$routeParams', function($routeParams) {
      this.name = "AboutCtrl";
      this.params = $routeParams;
    }])
    .controller('LoginCtrl', ['$routeParams', '$cookies', function($routeParams, $cookies) {
      this.name = "LoginCtrl";
      this.params = $routeParams;
      this.username = $cookies.username;
      this.isGuest = !this.username;
      this.test = 'hello world';
      alert(this.username);
    }]);
})(window.angular);
