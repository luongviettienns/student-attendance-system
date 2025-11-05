app.controller('LecturerTimetableController', ['$scope', '$rootScope', '$location', 'TimetableApi', 'AuthService', function($scope, $rootScope, $location, TimetableApi, AuthService) {
  function getIsoWeek(d) {
    var date = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
    var dayNum = date.getUTCDay() || 7;
    date.setUTCDate(date.getUTCDate() + 4 - dayNum);
    var yearStart = new Date(Date.UTC(date.getUTCFullYear(),0,1));
    var weekNo = Math.ceil((((date - yearStart) / 86400000) + 1)/7);
    return { year: date.getUTCFullYear(), week: weekNo };
  }

  $scope.today = new Date();
  var iso = getIsoWeek($scope.today);
  $scope.year = iso.year;
  $scope.week = iso.week;
  $scope.days = [1,2,3,4,5,6,7];
  $scope.loading = false;
  $scope.error = null;
  $scope.currentUser = AuthService.getCurrentUser() || {};

  // Lấy params từ hashbang: #!/lecturer/timetable?lecturerId=LEC001&week=12&year=2025
  var qs = $location.search() || {};
  $scope.lecturerId = $scope.currentUser.lecturerId || qs.lecturerId || localStorage.getItem('test_lecturerId') || '';
  var qWeek = parseInt(qs.week);
  var qYear = parseInt(qs.year);
  if (!isNaN(qWeek) && qWeek >= 1 && qWeek <= 53) { $scope.week = qWeek; }
  if (!isNaN(qYear) && qYear > 2000 && qYear < 3000) { $scope.year = qYear; }

  $scope.load = function() {
    if(!$scope.lecturerId){
      $scope.error = 'Vui lòng nhập Lecturer ID để xem thời khóa biểu';
      return;
    }
    $scope.error = null;
    $scope.loading = true;
    TimetableApi.getLecturerWeek($scope.lecturerId, $scope.year, $scope.week).then(function(res){
      var data = (res.data && res.data.data) || [];
      $scope.debug = { lecturerId: $scope.lecturerId, year: $scope.year, week: $scope.week, count: data.length };
      var map = {};
      $scope.days.forEach(function(d){ map[d] = []; });
      data.forEach(function(s){
        if(s.weekday >= 1 && s.weekday <= 7){ map[s.weekday].push(s); }
      });
      $scope.grid = map;
      $scope.raw = data;
      if(data.length === 0){ $scope.error = 'Không có dữ liệu thời khóa biểu cho tuần này'; }
    }).catch(function(err){
      $scope.error = 'Lỗi: ' + (err.data && err.data.message) || err.statusText || 'Không thể tải thời khóa biểu';
      console.error('Lecturer timetable load error:', err);
    }).finally(function(){ $scope.loading = false; });
  };

  $scope.setLecturerId = function(id){
    $scope.lecturerId = id;
    localStorage.setItem('test_lecturerId', id);
    $scope.load();
  };

  $scope.prevWeek = function(){
    var d = new Date($scope.today); d.setDate(d.getDate() - 7);
    $scope.today = d; var i = getIsoWeek(d); $scope.year = i.year; $scope.week = i.week; $scope.load();
  };
  $scope.nextWeek = function(){
    var d = new Date($scope.today); d.setDate(d.getDate() + 7);
    $scope.today = d; var i = getIsoWeek(d); $scope.year = i.year; $scope.week = i.week; $scope.load();
  };

  $scope.load();
}]);




