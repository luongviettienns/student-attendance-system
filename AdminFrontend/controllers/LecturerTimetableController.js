app.controller('LecturerTimetableController', ['$scope', '$rootScope', '$location', 'TimetableApi', 'AuthService', 'LecturerService', 'LoggerService', function($scope, $rootScope, $location, TimetableApi, AuthService, LecturerService, LoggerService) {
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
  $scope.days = [2,3,4,5,6,7,8]; // Thứ 2 đến Chủ nhật (2=Monday, 8=Sunday)
  $scope.periods = [1,2,3,4,5,6,7,8,9,10,11,12]; // Tiết 1 đến Tiết 12
  $scope.loading = false;
  $scope.error = null;
  $scope.currentUser = AuthService.getCurrentUser() || {};
  
  // Helper để lấy tên thứ
  $scope.getDayName = function(day) {
    var names = {2: 'Thứ 2', 3: 'Thứ 3', 4: 'Thứ 4', 5: 'Thứ 5', 6: 'Thứ 6', 7: 'Thứ 7', 8: 'CN'};
    return names[day] || 'Thứ ' + day;
  };
  
  // ✅ Helper: Tính ngày cho mỗi thứ trong tuần (ISO week)
  function getDateForWeekday(year, week, weekday) {
    // ISO week: Thứ 2 (2) là ngày đầu tuần
    // Get January 4th of the year (always in week 1 of ISO week)
    var jan4 = new Date(year, 0, 4);
    var jan4Day = jan4.getDay() || 7; // Convert Sunday (0) to 7
    
    // Calculate the Monday of week 1
    var mondayOfWeek1 = new Date(jan4);
    mondayOfWeek1.setDate(jan4.getDate() - (jan4Day - 1));
    
    // Calculate the date for the given week and weekday
    // weekday: 2=Monday, 3=Tuesday, ..., 8=Sunday
    var targetDate = new Date(mondayOfWeek1);
    targetDate.setDate(mondayOfWeek1.getDate() + (week - 1) * 7 + (weekday - 2));
    
    return targetDate;
  }
  
  // ✅ Helper: Format ngày (dd/MM)
  $scope.formatDate = function(date) {
    if (!date) return '';
    var day = ('0' + date.getDate()).slice(-2);
    var month = ('0' + (date.getMonth() + 1)).slice(-2);
    return day + '/' + month;
  };
  
  // ✅ Helper: Lấy ngày cho mỗi thứ
  $scope.getDayDate = function(day) {
    return getDateForWeekday($scope.year, $scope.week, day);
  };
  
  // ✅ Helper: Lấy thời gian cho mỗi tiết (theo PeriodCalculator)
  $scope.getPeriodTime = function(period) {
    var periodTimes = {
      1: '07:00-07:50',
      2: '07:55-08:45',
      3: '09:00-09:50',
      4: '09:55-10:45',
      5: '10:50-11:40',
      6: '11:45-12:35',
      7: '12:40-13:30',
      8: '13:35-14:25',
      9: '14:30-15:20',
      10: '15:25-16:15',
      11: '16:20-17:10',
      12: '17:15-18:05'
    };
    return periodTimes[period] || '';
  };
  
  // Kiểm tra role của user
  var userRole = $scope.currentUser.roleName || $scope.currentUser.Role || $scope.currentUser.role || '';
  $scope.isLecturer = userRole === 'Lecturer' || userRole === 'Giảng viên';
  $scope.isAdmin = userRole === 'Admin' || userRole === 'Quản trị viên';

  // Lấy params từ hashbang: #!/lecturer/timetable?lecturerId=LEC001&week=12&year=2025
  var qs = $location.search() || {};
  var qWeek = parseInt(qs.week);
  var qYear = parseInt(qs.year);
  if (!isNaN(qWeek) && qWeek >= 1 && qWeek <= 53) { $scope.week = qWeek; }
  if (!isNaN(qYear) && qYear > 2000 && qYear < 3000) { $scope.year = qYear; }

  // Khởi tạo lecturerId
  $scope.lecturerId = '';
  $scope.loadingLecturer = false;

  // Hàm lấy lecturerId từ userId
  function loadLecturerId() {
    if ($scope.isLecturer && $scope.currentUser.userId) {
      $scope.loadingLecturer = true;
      LecturerService.getByUserId($scope.currentUser.userId)
        .then(function(response) {
          var lecturer = response.data && response.data.data ? response.data.data : response.data;
          if (lecturer && lecturer.lecturerId) {
            $scope.lecturerId = lecturer.lecturerId;
            $scope.load();
          } else {
            $scope.error = 'Không tìm thấy thông tin giảng viên cho tài khoản này.';
          }
        })
        .catch(function(err) {
          $scope.error = 'Không thể tải thông tin giảng viên: ' + (err.data?.message || err.message || 'Lỗi không xác định');
          LoggerService.error('Get lecturer by userId error', err);
        })
        .finally(function() {
          $scope.loadingLecturer = false;
        });
    } else if ($scope.isAdmin) {
      // Admin có thể nhập lecturerId thủ công hoặc từ query string
      $scope.lecturerId = qs.lecturerId || localStorage.getItem('test_lecturerId') || '';
      if ($scope.lecturerId) {
        $scope.load();
      }
    } else {
      $scope.error = 'Bạn không có quyền xem thời khóa biểu giảng viên.';
    }
  }

  $scope.load = function() {
    if(!$scope.lecturerId){
      if ($scope.isLecturer) {
        $scope.error = 'Đang tải thông tin giảng viên...';
      } else {
        $scope.error = 'Vui lòng nhập Lecturer ID để xem thời khóa biểu';
      }
      return;
    }
    $scope.error = null;
    $scope.loading = true;
    TimetableApi.getLecturerWeek($scope.lecturerId, $scope.year, $scope.week).then(function(res){
      var data = (res.data && res.data.data) || [];
      $scope.debug = { lecturerId: $scope.lecturerId, year: $scope.year, week: $scope.week, count: data.length };
      
      // ✅ Tạo grid 2D: grid[weekday][period] = session
      var grid = {};
      $scope.days.forEach(function(day){
        grid[day] = {};
        $scope.periods.forEach(function(period){
          grid[day][period] = null; // Khởi tạo rỗng
        });
      });
      
      // Map sessions vào grid theo weekday và period
      data.forEach(function(s){
        var weekday = s.weekday;
        // Chuyển đổi weekday: 1=CN -> 8, 2=T2 -> 2, ..., 7=T7 -> 7
        if(weekday === 1) weekday = 8; // Chủ nhật
        else if(weekday >= 2 && weekday <= 7) weekday = weekday; // Thứ 2-7 giữ nguyên
        else return; // Bỏ qua nếu không hợp lệ
        
        if(!grid[weekday]) return;
        
        // Lấy period từ periodFrom và periodTo
        var periodFrom = s.periodFrom || s.period_from;
        var periodTo = s.periodTo || s.period_to;
        
        if(periodFrom && periodTo) {
          // Nếu có period, đặt session vào các tiết tương ứng
          for(var p = periodFrom; p <= periodTo; p++) {
            if(grid[weekday][p] === null) {
              grid[weekday][p] = s; // Chỉ đặt vào tiết đầu, các tiết sau sẽ merge
            } else if(Array.isArray(grid[weekday][p])) {
              grid[weekday][p].push(s);
            } else {
              // Nếu đã có session, chuyển thành array
              grid[weekday][p] = [grid[weekday][p], s];
            }
          }
        } else {
          // Nếu không có period, tính từ startTime
          var startTime = s.startTime || s.start_time;
          if(startTime) {
            var timeStr = startTime.toString();
            var hour = parseInt(timeStr.split(':')[0]);
            var period = Math.floor((hour - 7) / 1.5) + 1; // Ước tính: 7:00 = Tiết 1, 8:30 = Tiết 2, ...
            if(period >= 1 && period <= 12) {
              if(grid[weekday][period] === null) {
                grid[weekday][period] = s;
              } else if(Array.isArray(grid[weekday][period])) {
                grid[weekday][period].push(s);
              } else {
                grid[weekday][period] = [grid[weekday][period], s];
              }
            }
          }
        }
      });
      
      $scope.grid = grid;
      $scope.raw = data;
      if(data.length === 0){ $scope.error = 'Không có dữ liệu thời khóa biểu cho tuần này'; }
    }).catch(function(err){
      $scope.error = 'Lỗi: ' + ((err.data && err.data.message) || err.statusText || 'Không thể tải thời khóa biểu');
      LoggerService.error('Lecturer timetable load error', err);
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

  // Khởi tạo: tự động lấy lecturerId cho giảng viên
  loadLecturerId();
}]);




