InquirlyApp.directive('profileStatus', function() {

    return {
        restrict: 'E',
        templateUrl: "/ng-app/templates/configure/profileDropDown.html",
        replace: false,
        scope: {
            data: '=profileData'
        },
        link: function(scope) {

            scope.render = function(data) {
                if (!_.isUndefined(data)) {
                    var equal_distribution = 1 / (scope.data.length) * 100;
                    scope.weighted_distribution = [];
                    scope.percent_completion = 0;
                    scope.total_sum = 0;
                    scope.completed_sum = 0;
                    angular.forEach(scope.data, function(value) {
                        scope.total_sum += (value.weight * equal_distribution);
                        if (value.completed == true) {
                            scope.completed_sum += (value.weight * equal_distribution);
                        }
                        scope.percent_completion = ((scope.completed_sum / scope.total_sum) * 100);
                    });
                    scope.percent_completion = Math.round(scope.percent_completion);
                }
            };

            scope.$watch('data', function(newValue) {
                scope.render(newValue);
            }, true);
        }
    };
});

InquirlyApp.directive('setClassWhenAtTop', function($window) {
    var $win = angular.element($window);
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            var topClass = attrs.setClassWhenAtTop,
                offsetTop = element.offset().top;

            $win.on('scroll', function(e) {
                if ($win.scrollTop() >= offsetTop) {
                    element.addClass(topClass);
                } else {
                    element.removeClass(topClass);
                }
            });
        }
    };
});

InquirlyApp.directive('dropdownMultiselect', function() {
    return {
        restrict: 'E',
        scope: {
            model: '=',
            name: '=modelName',
            options: '=',
            pre_selected: '=preSelected'
        },
        template: "<div class='form-control' data-ng-click='openDropdown()' style='border: 1px solid #E7E7E7;height: 46px;border-radius: 8px;line-height: 34px;font-size: 12px;' data-ng-class='{open: open}'>" +
            "Select {{ name }}" +
            "<span class='dropdown-toggle' data-ng-click='openDropdown()'>" +
            "<span class='caret' style='position: relative; float: right; left: 6px; top: 15px;'></span></span>" +
            "<ul class='dropdown-menu' data-ng-show='open' style='width: 404px; margin-left: 15px; border-radius: 0; border: 1px solid #E7E7E7; top: 93%; -webkit-box-shadow: 0px 0px 0px 0px rgba(0,0,0,0.2); box-shadow: 0px 0px 0px 0px rgba(0,0,0,0.2);'>" +
            "<li data-ng-repeat='option in options' data-ng-click='setSelectedItem()' style='line-height:24px; cursor:pointer; padding-left: 10px; font-size: 12px; padding-right: 10px;'> <span>{{option.name}}<span style='line-height:20px;' data-ng-class='isChecked(option.id)'></span></span></li>" +
            "</ul>" +
            "</div>",
        controller: function($scope) {

            $scope.openDropdown = function() {
                $scope.open = !$scope.open;
                $scope.selected_items = [];
                for (var i = 0; i < $scope.pre_selected.length; i++) {
                    $scope.selected_items.push($scope.pre_selected[i].id);
                }
            };

            $scope.setSelectedItem = function() {
                $scope.open = false;
                var id = this.option.id;
                if (_.contains($scope.model, id)) {
                    $scope.model = _.without($scope.model, id);
                } else {
                    $scope.model.push(id);
                }
                return false;
            };

            $scope.isChecked = function(id) {
                if (_.contains($scope.model, id)) {
                    return 'fa fa-check pull-right';
                }
                return false;
            };
        }
    }
});