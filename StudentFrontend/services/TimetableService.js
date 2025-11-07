app.factory('TimetableApi', ['$http', 'API_CONFIG', function($http, API_CONFIG) {
  var base = API_CONFIG.BASE_URL;
  return {
    getStudentWeek: function(studentId, year, week) {
      return $http.get(base + '/timetable/student', { params: { studentId: studentId, year: year, week: week } });
    },
    getLecturerWeek: function(lecturerId, year, week) {
      return $http.get(base + '/timetable/lecturer', { params: { lecturerId: lecturerId, year: year, week: week } });
    }
  };
}]);


