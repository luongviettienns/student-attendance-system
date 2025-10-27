// Generic API Service
app.service('ApiService', ['$http', 'API_CONFIG', function($http, API_CONFIG) {
    
    this.get = function(endpoint, params) {
        // Wrap params trong { params: ... } để Angular $http convert thành query string
        var config = params ? { params: params } : {};
        return $http.get(API_CONFIG.BASE_URL + endpoint, config);
    };
    
    this.post = function(endpoint, data) {
        return $http.post(API_CONFIG.BASE_URL + endpoint, data);
    };
    
    this.put = function(endpoint, data) {
        return $http.put(API_CONFIG.BASE_URL + endpoint, data);
    };
    
    this.delete = function(endpoint, data) {
        return $http.delete(API_CONFIG.BASE_URL + endpoint, {
            headers: {'Content-Type': 'application/json'},
            data: data
        });
    };
    
    this.uploadFile = function(endpoint, formData) {
        return $http.post(API_CONFIG.BASE_URL + endpoint, formData, {
            transformRequest: angular.identity,
            headers: {'Content-Type': undefined}
        });
    };
}]);

