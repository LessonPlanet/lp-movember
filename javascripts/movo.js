"use strict";
angular.module('movo', [])
.controller('MainCtrl', function($scope) {
  $scope.users = [
    {handle: 'forest', name: 'Forest'},
    {handle: 'jon', name: 'Jon'},
    {handle: 'jrust', name: 'Jason'},
    {handle: 'simeon', name: 'Simeon'}
  ];

  var calculateDates = function() {
    var today = new Date(),
        start = new Date('November 1, 2013'),
        end = new Date('November 30, 2013'),
        dayRange = [];
    end = end > today ? today : end;

    for (start; start <= end; start.setDate(start.getDate() + 1)) {
      dayRange.push(start.toISOString().substr(0, 10));
    }
    return dayRange;
  };
  $scope.dates = calculateDates();
})
.directive('missingImage', function() {
  return {
    restrict: 'A',
    link: function($scope, $element, $attrs) {
      $element.bind('error', function() {
        $element.addClass('js-missing-image ng-hide');
      });
    }
  }
})
.directive('flipbook', function($timeout) {
  var imageMap = {};

  function flip(flipbook) {
    var images = flipbook.elements.filter(function(el) {
      return !el.hasClass('js-missing-image');
    });

    if (flipbook.currentIndex >= images.length - 1) {
      flipbook.currentIndex = 0;
    }
    else {
      flipbook.currentIndex += 1;
    }

    angular.forEach(images, function(el, idx) {
      if (idx == flipbook.currentIndex) {
        el.addClass('ng-show').removeClass('ng-hide hidden');
      }
      else {
        el.addClass('ng-hide').removeClass('ng-show');
      }
    });

    flipLoop(flipbook);
  }

  function flipLoop(flipbook, timeout) {
    $timeout(function() { flip(flipbook); }, 500);
  }

  return {
    restrict: 'A',
    link: function($scope, $element, $attrs) {
      if (!angular.isObject(imageMap[$scope.user.handle])) {
        imageMap[$scope.user.handle] = {currentIndex: -1, elements: []};
        flipLoop(imageMap[$scope.user.handle]);
      }

      imageMap[$scope.user.handle].elements.push($element);
    }
  }
});
