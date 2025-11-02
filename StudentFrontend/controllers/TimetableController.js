app.controller('TimetableController', ['$scope', '$rootScope', '$location', '$timeout', 'TimetableApi', 'AuthService', 'StudentService', 'SchoolYearService', function($scope, $rootScope, $location, $timeout, TimetableApi, AuthService, StudentService, SchoolYearService) {
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
  $scope.studentId = null;

  // Dropdown data
  $scope.schoolYears = [];
  $scope.selectedSchoolYearId = null;
  $scope.selectedWeek = null;
  $scope.availableWeeks = [];

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
    // SchoolYear has yearCode (e.g., "2024-2025") and startDate
    var startYear = new Date().getFullYear();
    if (selectedYear.startDate) {
      var startDate = new Date(selectedYear.startDate);
      startYear = startDate.getFullYear();
    } else if (selectedYear.yearCode) {
      var yearMatch = selectedYear.yearCode.match(/(\d{4})/);
      startYear = yearMatch ? parseInt(yearMatch[1]) : new Date().getFullYear();
    } else if (selectedYear.schoolYearCode) {
      var yearMatch2 = selectedYear.schoolYearCode.match(/(\d{4})/);
      startYear = yearMatch2 ? parseInt(yearMatch2[1]) : new Date().getFullYear();
    }

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
    console.log('onSchoolYearChange called, selectedSchoolYearId:', $scope.selectedSchoolYearId);
    $scope.generateWeeks();
    // Set default week to 1 or current week if available
    if ($scope.availableWeeks.length > 0) {
      var currentWeek = parseInt($scope.week) || 12;
      if (currentWeek >= 1 && currentWeek <= 53) {
        $scope.selectedWeek = String(currentWeek); // Ensure string for ng-model
      } else {
        $scope.selectedWeek = '12'; // Default to week 12
      }
      console.log('Setting selectedWeek to:', $scope.selectedWeek);
      // Use $timeout to ensure DOM is updated before calling onWeekChange
      $timeout(function() {
        $scope.onWeekChange();
      }, 0);
    }
  };

  // Handle week change
  $scope.onWeekChange = function() {
    console.log('onWeekChange called, selectedWeek:', $scope.selectedWeek, 'type:', typeof $scope.selectedWeek);
    if ($scope.selectedWeek !== null && $scope.selectedWeek !== undefined && $scope.selectedWeek !== '') {
      // Convert to number if it's a string
      var weekNum = typeof $scope.selectedWeek === 'string' ? parseInt($scope.selectedWeek) : $scope.selectedWeek;
      if (!isNaN(weekNum) && weekNum >= 1 && weekNum <= 53) {
        $scope.week = weekNum;
        // Extract year from selected school year
        var selectedYear = $scope.schoolYears.find(function(sy) {
          return sy.schoolYearId === $scope.selectedSchoolYearId;
        });
        if (selectedYear) {
          console.log('Selected year object:', selectedYear);
          if (selectedYear.startDate) {
            var startDate = new Date(selectedYear.startDate);
            $scope.year = startDate.getFullYear();
            console.log('Using startDate year:', $scope.year);
          } else if (selectedYear.yearCode) {
            var yearMatch = selectedYear.yearCode.match(/(\d{4})/);
            $scope.year = yearMatch ? parseInt(yearMatch[1]) : new Date().getFullYear();
            console.log('Using yearCode year:', $scope.year, 'from yearCode:', selectedYear.yearCode);
          } else if (selectedYear.schoolYearCode) {
            var yearMatch2 = selectedYear.schoolYearCode.match(/(\d{4})/);
            $scope.year = yearMatch2 ? parseInt(yearMatch2[1]) : new Date().getFullYear();
            console.log('Using schoolYearCode year:', $scope.year, 'from schoolYearCode:', selectedYear.schoolYearCode);
          } else {
            // Fallback: try to get year from current date or default
            $scope.year = new Date().getFullYear();
            console.warn('No year found in selectedYear, using current year:', $scope.year);
          }
        } else {
          console.warn('No selectedYear found, using current year');
          $scope.year = new Date().getFullYear();
        }
        console.log('Loading timetable for week:', $scope.week, 'year:', $scope.year, 'studentId:', $scope.studentId);
        if ($scope.studentId) {
          $scope.load();
        }
      } else {
        console.warn('Invalid week number:', weekNum);
      }
    } else {
      console.warn('selectedWeek is empty or undefined');
    }
  };

  // Load school years
  $scope.loadAcademicYears = function() {
    // Try to get active school year first (has AllowAnonymous)
    // If that fails, try getAll
    SchoolYearService.getActive().then(function(res) {
      // getActive returns single object, convert to array
      var activeYear = res.data;
      if (activeYear && activeYear.schoolYearId) {
        $scope.schoolYears = [activeYear];
        console.log('Loaded active school year:', activeYear);
        $scope.selectedSchoolYearId = activeYear.schoolYearId;
        $scope.generateWeeks();
        if ($scope.availableWeeks.length > 0) {
          var weekValue = String($scope.week || 12);
          if (parseInt(weekValue) < 1 || parseInt(weekValue) > 53) {
            weekValue = '12';
          }
          $scope.selectedWeek = weekValue;
          $scope.onWeekChange();
        }
      } else {
        // Fallback to getAll
        return SchoolYearService.getAll();
      }
    }).catch(function(err) {
      // If getActive fails, try getAll
      console.log('getActive failed, trying getAll:', err);
      return SchoolYearService.getAll();
    }).then(function(res) {
      if (!res) return; // Already handled in getActive
      
      console.log('School years response:', res);
      // Backend returns array directly: [...]
      // Check if it's wrapped in data property or direct array
      $scope.schoolYears = Array.isArray(res.data) ? res.data : (res.data && Array.isArray(res.data.data) ? res.data.data : []);
      console.log('Loaded school years:', $scope.schoolYears.length, $scope.schoolYears);
      
      if ($scope.schoolYears.length > 0) {
        // Set default to active school year or current year
        var currentYear = new Date().getFullYear();
        var activeYear = $scope.schoolYears.find(function(sy) {
          return sy.isActive === true;
        });
        var defaultYear = activeYear || $scope.schoolYears.find(function(sy) {
          return sy.yearCode && sy.yearCode.includes(currentYear.toString());
        });
        $scope.selectedSchoolYearId = defaultYear ? defaultYear.schoolYearId : $scope.schoolYears[0].schoolYearId;
        console.log('Selected school year ID:', $scope.selectedSchoolYearId);
        $scope.generateWeeks();
        // Set default week - ensure string for ng-model
        if ($scope.availableWeeks.length > 0) {
          var weekValue = String($scope.week || 12);
          if (parseInt(weekValue) < 1 || parseInt(weekValue) > 53) {
            weekValue = '12';
          }
          $scope.selectedWeek = weekValue;
          console.log('Selected week:', $scope.selectedWeek);
          $scope.onWeekChange();
        }
      } else {
        console.warn('No school years found');
      }
    }).catch(function(err) { 
      console.error('Load school years error:', err);
      // Fallback to default
      $scope.schoolYears = [{ schoolYearId: 'SY2024', yearCode: '2024-2025' }];
      $scope.selectedSchoolYearId = 'SY2024';
      $scope.generateWeeks();
      if ($scope.availableWeeks.length > 0) {
        $scope.selectedWeek = String($scope.week || 12);
        $scope.onWeekChange();
      }
    });
  };
  
  // Load student ID from user
  function loadStudentId() {
    if (!$scope.currentUser || !$scope.currentUser.userId) {
      $scope.error = 'Không tìm thấy thông tin người dùng';
      $scope.loading = false;
      return;
    }
    
    // Check if studentId is already in currentUser
    if ($scope.currentUser.studentId) {
      $scope.studentId = $scope.currentUser.studentId;
      // Get params from query string
      var qs = $location.search() || {};
      var qWeek = parseInt(qs.week);
      var qYear = parseInt(qs.year);
      if (!isNaN(qWeek) && qWeek >= 1 && qWeek <= 53) { $scope.week = qWeek; }
      if (!isNaN(qYear) && qYear > 2000 && qYear < 3000) { $scope.year = qYear; }
      $scope.load();
      return;
    }
    
    // Otherwise, fetch from API
    StudentService.getByUserId($scope.currentUser.userId)
      .then(function(response) {
        if (response.data && response.data.data) {
          $scope.studentId = response.data.data.studentId;
          // Get params from query string
          var qs = $location.search() || {};
          var qWeek = parseInt(qs.week);
          var qYear = parseInt(qs.year);
          if (!isNaN(qWeek) && qWeek >= 1 && qWeek <= 53) { $scope.week = qWeek; }
          if (!isNaN(qYear) && qYear > 2000 && qYear < 3000) { $scope.year = qYear; }
          $scope.load();
        } else {
          $scope.error = 'Không tìm thấy thông tin sinh viên';
          $scope.loading = false;
        }
      })
      .catch(function(error) {
        console.error('Error loading student info:', error);
        $scope.error = 'Không thể tải thông tin sinh viên. Vui lòng thử lại sau.';
        $scope.loading = false;
      });
  }

  $scope.load = function() {
    if(!$scope.studentId){
      $scope.error = 'Vui lòng nhập Student ID để xem thời khóa biểu';
      return;
    }
    $scope.error = null;
    $scope.loading = true;
    
    // Debug logging
    console.log('Loading timetable:', {
      studentId: $scope.studentId,
      year: $scope.year,
      week: $scope.week,
      selectedSchoolYearId: $scope.selectedSchoolYearId
    });
    
    TimetableApi.getStudentWeek($scope.studentId, $scope.year, $scope.week).then(function(res){
      console.log('Timetable API response:', res);
      var data = (res.data && res.data.data) || [];
      console.log('Timetable data:', data);
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
        $scope.error = 'Không có dữ liệu thời khóa biểu cho tuần này. Kiểm tra: 1) Sinh viên đã được gán vào lớp chưa? 2) Lớp có lịch học tuần ' + $scope.week + ' không? 3) Year có đúng không? (hiện tại: ' + $scope.year + ')';
        console.warn('No timetable data found. Debug info:', $scope.debug);
      } else {
        console.log('Timetable loaded successfully:', data.length, 'sessions');
      }
    }).catch(function(err){
      $scope.error = 'Lỗi: ' + (err.data && err.data.message) || err.statusText || 'Không thể tải thời khóa biểu';
      console.error('Timetable load error:', err);
      if (err.data) {
        console.error('Error details:', JSON.stringify(err.data, null, 2));
      }
    }).finally(function(){ $scope.loading = false; });
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
  loadStudentId();
  // Load academic years after student ID is loaded
  $scope.$watch('studentId', function(newVal) {
    if (newVal) {
      $scope.loadAcademicYears();
    }
  });
}]);


