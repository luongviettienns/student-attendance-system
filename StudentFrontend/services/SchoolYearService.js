// School Year Service
app.service('SchoolYearService', ['ApiService', function(ApiService) {
    
    // Get all school years
    this.getAll = function() {
        return ApiService.get('/school-years').then(function(response) {
            if (response.data && response.data.data) {
                response.data = response.data.data;
            }
            return response;
        });
    };
    
    // Get current school year (based on current date)
    this.getCurrent = function() {
        return ApiService.get('/school-years/current');
    };
    
    // Get active school year (is_active = 1)
    this.getActive = function() {
        return ApiService.get('/school-years/active');
    };
    
    // Get current semester info
    this.getCurrentSemesterInfo = function() {
        return ApiService.get('/school-years/current-semester-info');
    };
    
    // Get school year by ID
    this.getById = function(id) {
        return ApiService.get('/school-years/' + id);
    };
}]);


