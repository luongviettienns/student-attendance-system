// Grade Service
app.service('GradeService', ['ApiService', function(ApiService) {
    
    this.getByStudentSchoolYear = function(studentId, schoolYearId, semester) {
        var url = '/grades/student/' + studentId + '/school-year/' + schoolYearId;
        if (semester) url += '?semester=' + semester;
        return ApiService.get(url);
    };
    
    this.getGradeSummary = function(studentId, schoolYearId, semester) {
        var url = '/grades/student/' + studentId + '/summary';
        var params = [];
        if (schoolYearId) params.push('schoolYearId=' + schoolYearId);
        if (semester) params.push('semester=' + semester);
        if (params.length) url += '?' + params.join('&');
        return ApiService.get(url);
    };
}]);


