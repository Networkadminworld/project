InquirlyApp.directive('backImg', function(){
    return function(scope, element, attrs){
        attrs.$observe('backImg', function(value) {
            var url = attrs.backImg;
            var size = attrs.backImgSize || 'cover';
            var width = attrs.backImgWidth;
            var height = attrs.backImgHeight;
            element.css({
                'background-repeat' : 'no-repeat',
                'background-image': value == '' ? 'url("/ng-app/Images/thumbnail-default.jpg")' : 'url(' + value +')',
                'background-size' : size,
                '-webkit-background-size': size,
                '-moz-background-size': size,
                '-ms-background-size': size,
                'width': width,
                'height': height
            });
        });
    };
});

InquirlyApp.directive('profileImg', function(){
    return function(scope, element, attrs){
        attrs.$observe('profileImg', function(value) {
            var url = attrs.backImg;
            var size = attrs.backImgSize || 'cover';
            var width = attrs.backImgWidth;
            var height = attrs.backImgHeight;
            element.css({
                'background-repeat' : 'no-repeat',
                'background-image': value == '' ? 'url("/ng-app/Images/default_user_image.jpg")' : 'url(' + value +')',
                'background-size' : size,
                '-webkit-background-size': size,
                '-moz-background-size': size,
                '-ms-background-size': size,
                'width': width,
                'height': height
            });
        });
    };
});

InquirlyApp.directive('userImg', function(){
    return function(scope, element, attrs){
        attrs.$observe('userImg', function(value) {
            var url = attrs.backImg;
            var size = attrs.backImgSize || 'cover';
            var width = attrs.backImgWidth;
            var height = attrs.backImgHeight;
            element.css({
                'background-repeat' : 'no-repeat',
                'background-image': value == '' ? 'url("/ng-app/Images/user-avatar.png")' : 'url(' + value +')',
                'background-size' : size,
                '-webkit-background-size': size,
                '-moz-background-size': size,
                '-ms-background-size': size,
                'width': width,
                'height': height
            });
        });
    };
});

InquirlyApp.directive('socialImg', function(){
    return function(scope, element, attrs){
        attrs.$observe('socialImg', function(value) {
            var url = attrs.socialImg;
            var size = '100% 100%';
            var width = '30px';
            var height = '30px';
            var radius =  '50px';
            var border = '1px';
            element.css({
                'background-repeat' : 'no-repeat',
                'background-image': value == '' ? 'url("/ng-app/Images/thumbnail-default.jpg")' : 'url(' + value +')',
                'background-size' : size,
                '-webkit-background-size': size,
                '-moz-background-size': size,
                '-ms-background-size': size,
                'width': width,
                'height': height,
                'border-radius': radius,
                'border': border
            });
        });
    };
});

var directiveName = "anyOtherClick";
InquirlyApp.directive(directiveName, ['$document', "$parse", function ($document, $parse) {
    return {
        restrict: 'A',
        link:  function (scope, element, attr, controller) {
            var anyOtherClickFunction = $parse(attr[directiveName]);
            var documentClickHandler = function (event) {
                var eventOutsideTarget = (element[0] !== event.target) && (0 === element.find(event.target).length);
                if (eventOutsideTarget) {
                    scope.$apply(function () {
                        anyOtherClickFunction(scope, {});
                    });
                }
            };

            $document.on("click", documentClickHandler);
            scope.$on("$destroy", function () {
                $document.off("click", documentClickHandler);
            });
        }
    };
}]);