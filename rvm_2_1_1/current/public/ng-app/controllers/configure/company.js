InquirlyApp.controller('CompanyController', function($scope,$rootScope, $http, $sce,Upload,fileReader,Onboarding) {
  $http.get('/companies.json').success(function(data,status, headers, config) {
              $scope.formData = data.data || {};
              $scope.industry_types = data.industry_types;
              $scope.image = data.attachment || '';
              $scope.imageText = $scope.image ? 'Change Image' : 'Upload Image';
              $scope.formData.tags = data.tags || '';
              if(!_.isEmpty(data.data)) { $scope.industry_id = data.data.industry_id }
  });

    $scope.onImageSelect = function(files) {
        var file = files[0];
        if(file && file.type.match(/^image\/.*/)){
            fileReader.readAsDataUrl(file, $scope)
                .then(function(result) {
                    $scope.image = result;
                });
        }
    };

    $scope.updateTags = function(id){
        var url = '/companies/get_tags?industry_id='+id;
        $http.get(url).success(function(data,status, headers, config) {
            $scope.formData.tags = data;
        });
    };

  $scope.buttonText = 'SAVE CHANGES';
  $scope.isNameDuplicate = false;

  $scope.$watch('myForm.$dirty', function(validity) {
    $scope.submitted = false;
  });
  $scope.$watch('formData', function() {
      $scope.buttonText = 'SAVE CHANGES';
      $scope.submitted = false;
  }, true);
  $scope.submitted = false;
  $scope.submit = function(file) {
      $scope.buttonText = "SAVING... <i class='fa fa-spinner'></i>";
      $scope.submitted = true;
      if($scope.myForm.$invalid){ return; }
        if (file){
              $scope.upload = Upload.upload({
                  url: '/companies',
                  method: 'POST',
                  headers: {'X-CSRF-Token': $('meta[name=csrf-token]').attr('content')},
                  withCredentials: true,
                  fields: {
                      'company[name]': $scope.formData.name || '',
                      'company[address]': $scope.formData.address || '',
                      'company[area]': document.getElementById('txtPlaces').value || '',
                      'company[description]': $scope.formData.description || '',
                      'company[industry_id]': $scope.formData.industry_id,
                      'company[tags]': $scope.formData.tags,
                      'company[website_url]': $scope.formData.website_url || '',
                      'company[facebook_url]': $scope.formData.facebook_url || '',
                      'company[twitter_url]': $scope.formData.twitter_url || '',
                      'company[linkedin_url]': $scope.formData.linkedin_url || '',
                      'company[redirect_url]': $scope.formData.redirect_url || '',
                      'company[lat]': document.getElementById('lat').value,
                      'company[lng]': document.getElementById('lng').value
                  },
                  file: file,
                  fileFormDataName: 'company[data]'
              }).success(function (data, status, headers, config) {
                      serverResponse(data)
              })
        }
        else{
          $http.post('/companies', getCompanyFormInputs()).
              success(function(data, status, headers, config) {
                  serverResponse(data)
          })
        }

          function serverResponse(data){
              if(data.error){
                  $scope.isNameDuplicate = true;
                  $scope.myForm.$setPristine();
              }else{
                  $scope.isNameDuplicate = false;
                  set_global_values(data)
              }
          }

          function set_global_values(data){
            $scope.buttonText = 'SAVE CHANGES';
            $scope.company = data.data;
            $scope.submitted = false;
            $scope.myForm.$setPristine();
            Onboarding.update_status($scope.$parent.profileData);
            $rootScope.session.data.company_area = data.data.area;
            $rootScope.session.data.company_address = data.data.address;
            $rootScope.session.data.company_logo = data.attachment;
          }

          function getCompanyFormInputs(){
              var company = {};
              company["company"] = {};
              company["company"]["name"] = $scope.formData.name;
              company["company"]["address"] = $scope.formData.address;
              company["company"]["area"] = document.getElementById('txtPlaces').value;
              company["company"]["description"] = $scope.formData.description;
              company["company"]["industry_id"] = $scope.formData.industry_id;
              company["company"]["tags"] = $scope.formData.tags;
              company["company"]["website_url"] = $scope.formData.website_url;
              company["company"]["facebook_url"] = $scope.formData.facebook_url;
              company["company"]["twitter_url"] = $scope.formData.twitter_url;
              company["company"]["linkedin_url"] = $scope.formData.linkedin_url;
              company["company"]["redirect_url"] = $scope.formData.redirect_url;
              company["company"]["lat"] = document.getElementById('lat').value;
              company["company"]["lng"] = document.getElementById('lng').value;
              return company;
          }
    };

    $scope.parseContent = function(value) {
        return $sce.trustAsHtml(value);
    }
});
