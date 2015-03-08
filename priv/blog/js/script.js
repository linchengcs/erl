(function(angular) {
  'use strict';
  angular.module('ngBlog', ['ngRoute','ngCookies', 'ngSanitize', 'ui.tinymce'])
    .config(['$routeProvider', '$locationProvider',
             function($routeProvider, $locationProvider) {
               $routeProvider
                 .when('/index.html',{
                   templateUrl: 'about.html'
                 })
                 .when('/login',{
                   templateUrl: 'login.html',
                   controller: 'LoginCtrl',
                   controllerAs: 'login'
                 })
               .when('/blog',{
                 templateUrl: 'blog.html',
                 controller: 'BlogCtrl',
                 controllerAs: 'blog'
               });
               $locationProvider.html5Mode(true);
             }])
    .controller('MainCtrl', function(){})
    .controller('LoginCtrl', ['$routeParams', '$cookies','$http', '$scope',  function($routeParams, $cookies, $http, $scope) {
      this.name = "LoginCtrl";
      this.params = $routeParams;
      $scope.isGuest = !$cookies.token;
      $scope.errMsg = '';

      $scope.submit = function(){
        $http({
          method: 'POST',
          url: "../login",
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          transformRequest: function(obj) {
            var str = [];
            for(var p in obj)
              str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
            return str.join("&");
          },
          data: $scope.user
        })
          .success(function (data, status, header, config) {
            if (data.ret == 1) {$scope.errMsg = '用户名或密码错误';}
            $cookies.token = data.token;
            $scope.isGuest =!$cookies.token;
          })
          .error(function (data, status, header, config) {
            alert('login fail');
          });
      };

      $scope.logout = function(){
        $cookies.token = '';
        $scope.isGuest = true;
        $scope.errMsg = '';
      };

      /*
       $scope.get = function(){
       $http.get('http://localhost:8888').success(function(data, status, header, config){alert(data);});
       alert(1);
       };
       $scope.post = function(){
       $http.post('http://localhost:8888/login','username=rick&password=chenglin').success(function(data, status, header, config){alert(data);});
       };
       */
    }])
    .controller('BlogCtrl', ['$routeParams', '$cookies', '$http', '$scope', function($routeParams, $cookies, $http, $scope) {
      this.name = "BlogCtrl";
      $scope.params = $routeParams;
      $scope.page = 0;
      $scope.size = 10;
      $scope.show_form = false;
      $scope.form = {"title":"day","content":"","date":0, "tag":"day"};
      $scope.create = function(){
        $scope.form = {"title":"day","content":"","date":0, "tag":"day"};
        $scope.show_form = true;
      };
      $scope.update = function(old_post){
        $scope.show_form = true;
        $scope.form = old_post;
      };
      $scope.save = function(){
        $http({
          method: 'PUT',
          url: "../post_rest?token="+$cookies.token,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          transformRequest: function(obj) {
            var str = [];
            for(var p in obj)
              str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
            return str.join("&");
          },
          data: $scope.form
        })
          .success(function (data, status, header, config) {
            $scope.show_form = false;
            $scope.getPosts($scope.page, $scope.size);
          })
          .error(function (data, status, header, config) {
            alert('save post fail');
          });
      };
      $scope.delete = function(old_post){
        if (!confirm("sure?")) return 0;
        $http({
          method: 'DELETE',
          url: "../post_rest?token="+$cookies.token,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          transformRequest: function(obj) {
            var str = [];
            for(var p in obj)
              str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
            return str.join("&");
          },
          data: old_post
        })
          .success(function (data, status, header, config) {
            $scope.show_form = false;
            $scope.getPosts($scope.page, $scope.size);
          })
          .error(function (data, status, header, config) {
            alert('save post fail');
          });
      };
      $scope.cancel = function(){$scope.show_form = false;};

      $scope.getPosts = function (page, size) {
        $http({
          method: 'GET',
          url: '../post',
          params: {page:page, size:size, token:$cookies.token}
        })
          .success(function (data, status, header, config){
            if (page >= 0) {
              $scope.posts = data;
            }else{
              $scope.page_count = Math.floor(data.post_count/$scope.size);
            }
  //          alert(data[0].title);
//      alert($scope.posts);
          })
          .error(function (data, status, header, config) {
            alert('getPost fail');
            $scope.posts = null;
          });
      };
      $scope.getPosts(-1, $scope.size);
      $scope.getPosts($scope.page, $scope.size);
     $scope.timestring = function(seconds) {
        return (new Date((seconds - 62167241434 - 6600)*1000)).toLocaleString();
      };
    }]);
})(window.angular);
