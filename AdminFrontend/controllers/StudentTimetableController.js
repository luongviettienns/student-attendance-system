app.controller('StudentTimetableController', ['$scope', '$rootScope', '$location', 'TimetableApi', 'AuthService', 'AcademicYearService', function($scope, $rootScope, $location, TimetableApi, AuthService, AcademicYearService) {
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
  
  // Dropdown data
  $scope.schoolYears = [];
  $scope.selectedSchoolYearId = null;
  $scope.selectedWeek = null;
  $scope.availableWeeks = [];
  
  // Lấy params qua $location (đúng cho hashbang routing): #!/student/timetable?studentId=STU001&week=12&year=2025
  var qs = $location.search() || {};
  // Lấy studentId từ currentUser hoặc query hoặc localStorage (để test)
  $scope.studentId = $scope.currentUser.studentId || qs.studentId || localStorage.getItem('test_studentId') || '';
  // Cho phép override tuần/năm từ query string
  var qWeek = parseInt(qs.week);
  var qYear = parseInt(qs.year);
  if (!isNaN(qWeek) && qWeek >= 1 && qWeek <= 53) { $scope.week = qWeek; }
  if (!isNaN(qYear) && qYear > 2000 && qYear < 3000) { $scope.year = qYear; }

  // Helper: Get start date of a week based on week 12 starting from 3/11/2025
  function getWeekStartDate(year, week) {
    // Week 12 starts on 3/11/2025 (Monday)
    var week12StartDate = new Date(2025, 10, 3); // Month is 0-indexed, so 10 = November
    // Calculate the start date for the requested week
    // Week 1 is 11 weeks before week 12
    var week1StartDate = new Date(week12StartDate);
    week1StartDate.setDate(week1StartDate.getDate() - (12 - 1) * 7);
    
    // Calculate the start date for the requested week
    var weekStartDate = new Date(week1StartDate);
    weekStartDate.setDate(weekStartDate.getDate() + (week - 1) * 7);
    
    return weekStartDate;
  }

  // Helper: Format date to DD/MM/YYYY
  function formatDate(date) {
    var day = ('0' + date.getDate()).slice(-2);
    var month = ('0' + (date.getMonth() + 1)).slice(-2);
    var year = date.getFullYear();
    return day + '/' + month + '/' + year;
  }

  // Generate available weeks for selected school year
  $scope.generateWeeks = function() {
    if (!$scope.selectedSchoolYearId) {
      $scope.availableWeeks = [];
      return;
    }

    var selectedYear = $scope.schoolYears.find(function(sy) {
      return sy.schoolYearId === $scope.selectedSchoolYearId;
    });

    if (!selectedYear) {
      $scope.availableWeeks = [];
      return;
    }

    // Parse school year code (e.g., "2024-2025") to get start year
    var yearMatch = selectedYear.schoolYearCode.match(/(\d{4})/);
    var startYear = yearMatch ? parseInt(yearMatch[1]) : new Date().getFullYear();

    // Generate 53 weeks for the school year
    var weeks = [];
    for (var i = 1; i <= 53; i++) {
      var weekStart = getWeekStartDate(startYear, i);
      var weekEnd = new Date(weekStart);
      weekEnd.setDate(weekEnd.getDate() + 6);
      
      weeks.push({
        weekNo: i,
        label: 'Tuần ' + i + ' [Từ ' + formatDate(weekStart) + ' -- Đến ' + formatDate(weekEnd) + ']',
        startDate: weekStart,
        endDate: weekEnd
      });
    }
    $scope.availableWeeks = weeks;
  };

  // Handle school year change
  $scope.onSchoolYearChange = function() {
    $scope.generateWeeks();
    // Set default week to 1 or current week if available
    if ($scope.availableWeeks.length > 0) {
      var currentWeek = $scope.week || 12;
      if (currentWeek >= 1 && currentWeek <= 53) {
        $scope.selectedWeek = currentWeek;
      } else {
        $scope.selectedWeek = 1;
      }
      $scope.onWeekChange();
    }
  };

  // Handle week change
  $scope.onWeekChange = function() {
    if ($scope.selectedWeek) {
      $scope.week = parseInt($scope.selectedWeek);
      // Extract year from selected school year
      var selectedYear = $scope.schoolYears.find(function(sy) {
        return sy.schoolYearId === $scope.selectedSchoolYearId;
      });
      if (selectedYear) {
        var yearMatch = selectedYear.schoolYearCode.match(/(\d{4})/);
        $scope.year = yearMatch ? parseInt(yearMatch[1]) : new Date().getFullYear();
      }
      $scope.load();
    }
  };

  // Load academic years
  $scope.loadAcademicYears = function() {
    AcademicYearService.getAll().then(function(res) {
      $scope.schoolYears = (res.data && res.data.data) || res.data || [];
      if ($scope.schoolYears.length > 0) {
        // Set default to first school year or current year
        var currentYear = new Date().getFullYear();
        var defaultYear = $scope.schoolYears.find(function(sy) {
          return sy.schoolYearCode && sy.schoolYearCode.includes(currentYear.toString());
        });
        $scope.selectedSchoolYearId = defaultYear ? defaultYear.schoolYearId : $scope.schoolYears[0].schoolYearId;
        $scope.generateWeeks();
        // Set default week
        if ($scope.availableWeeks.length > 0) {
          $scope.selectedWeek = $scope.week || 12;
          if ($scope.selectedWeek < 1 || $scope.selectedWeek > 53) {
            $scope.selectedWeek = 12;
          }
          $scope.onWeekChange();
        }
      }
    }).catch(function(err) { 
      console.error('Load academic years error:', err);
      // Fallback to default
      $scope.schoolYears = [{ schoolYearId: 'SY2024', schoolYearCode: '2024-2025' }];
      $scope.selectedSchoolYearId = 'SY2024';
      $scope.generateWeeks();
      if ($scope.availableWeeks.length > 0) {
        $scope.selectedWeek = $scope.week || 12;
        $scope.onWeekChange();
      }
    });
  };

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
    if ($scope.selectedWeek && $scope.selectedWeek > 1) {
      $scope.selectedWeek = $scope.selectedWeek - 1;
      $scope.onWeekChange();
    }
  };
  $scope.nextWeek = function(){
    if ($scope.selectedWeek && $scope.selectedWeek < 53) {
      $scope.selectedWeek = $scope.selectedWeek + 1;
      $scope.onWeekChange();
    }
  };

  // Initialize
  $scope.loadAcademicYears();
}]);


