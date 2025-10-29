app.controller('StudentTimetableController', ['$scope', '$rootScope', '$location', 'TimetableApi', 'AuthService', function($scope, $rootScope, $location, TimetableApi, AuthService) {
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
  $scope.slots = [];
  $scope.loading = false;
  $scope.error = null;
  $scope.currentUser = AuthService.getCurrentUser() || {};
  
  // Lấy params qua $location (đúng cho hashbang routing): #!/student/timetable?studentId=STU001&week=12&year=2025
  var qs = $location.search() || {};
  // Lấy studentId từ currentUser hoặc query hoặc localStorage (để test)
  $scope.studentId = $scope.currentUser.studentId || qs.studentId || localStorage.getItem('test_studentId') || '';
  // Cho phép override tuần/năm từ query string
  var qWeek = parseInt(qs.week);
  var qYear = parseInt(qs.year);
  if (!isNaN(qWeek) && qWeek >= 1 && qWeek <= 53) { $scope.week = qWeek; }
  if (!isNaN(qYear) && qYear > 2000 && qYear < 3000) { $scope.year = qYear; }

  $scope.load = function() {
    if(!$scope.studentId){
      $scope.error = 'Vui lòng nhập Student ID để xem thời khóa biểu';
      return;
    }
    $scope.error = null;
    $scope.loading = true;
    TimetableApi.getStudentWeek($scope.studentId, $scope.year, $scope.week).then(function(res){
      var data = (res.data && res.data.data) || [];
      $scope.raw = data;
      $scope.debug = { studentId: $scope.studentId, year: $scope.year, week: $scope.week, count: data.length };
      // map theo weekday
      var map = {};
      $scope.days.forEach(function(d){ map[d] = []; });
      data.forEach(function(s){
        if(s.weekday >= 1 && s.weekday <= 7){
          map[s.weekday].push(s);
        }
      });
      $scope.grid = map;
      if(data.length === 0){
        $scope.error = 'Không có dữ liệu thời khóa biểu cho tuần này';
      }
    }).catch(function(err){
      $scope.error = 'Lỗi: ' + (err.data && err.data.message) || err.statusText || 'Không thể tải thời khóa biểu';
      console.error('Timetable load error:', err);
    }).finally(function(){ $scope.loading = false; });
  };
  
  $scope.setStudentId = function(id){
    $scope.studentId = id;
    localStorage.setItem('test_studentId', id);
    $scope.load();
  };

  $scope.prevWeek = function(){
    var d = new Date($scope.today);
    d.setDate(d.getDate() - 7);
    $scope.today = d;
    var i = getIsoWeek(d);
    $scope.year = i.year; $scope.week = i.week; $scope.load();
  };
  $scope.nextWeek = function(){
    var d = new Date($scope.today);
    d.setDate(d.getDate() + 7);
    $scope.today = d;
    var i = getIsoWeek(d);
    $scope.year = i.year; $scope.week = i.week; $scope.load();
  };

  $scope.load();
}]);


