app.controller('AdminTimetableController', ['$scope', '$rootScope', '$location', '$timeout', 'TimetableApi', 'ClassService', 'SubjectService', 'LecturerService', 'AuthService', 'ToastService', 'LoggerService', function($scope, $rootScope, $location, $timeout, TimetableApi, ClassService, SubjectService, LecturerService, AuthService, ToastService, LoggerService) {
  function getIsoWeek(d) {
    var date = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
    var dayNum = date.getUTCDay() || 7;
    date.setUTCDate(date.getUTCDate() + 4 - dayNum);
    var yearStart = new Date(Date.UTC(date.getUTCFullYear(),0,1));
    var weekNo = Math.ceil((((date - yearStart) / 86400000) + 1)/7);
    return { year: date.getUTCFullYear(), week: weekNo };
  }

  // Lấy params từ URL hoặc mặc định tuần 12
  var qs = $location.search() || {};
  var qWeek = parseInt(qs.week);
  var qYear = parseInt(qs.year);
  
  $scope.today = new Date();
  var iso = getIsoWeek($scope.today);
  // Mặc định tuần 12 nếu không có params
  $scope.year = !isNaN(qYear) && qYear > 2000 && qYear < 3000 ? qYear : iso.year;
  $scope.week = !isNaN(qWeek) && qWeek >= 1 && qWeek <= 53 ? qWeek : 12;
  $scope.days = [1,2,3,4,5,6,7];
  $scope.loading = false;
  $scope.error = null;
  $scope.currentUser = AuthService.getCurrentUser() || {};
  
  // Helper: Convert time string "HH:mm:ss" to "HH:mm" for input type="time"
  function timeToInput(timeStr) {
    if (!timeStr) return null; // Return null instead of empty string
    var str = String(timeStr);
    if (str.length >= 5) {
      return str.substring(0, 5); // "07:00:00" -> "07:00"
    }
    return str; // Already "HH:mm" or shorter
  }
  
  // Helper: Convert "HH:mm" to "HH:mm:ss" for API
  function timeToApi(timeStr) {
    if (!timeStr) return null;
    var str = String(timeStr);
    if (str.length === 5) return str + ':00'; // "07:00" -> "07:00:00"
    if (str.length === 8) return str; // Already "HH:mm:ss"
    return null; // Invalid format
  }

  // Form data - Initialize with null for time fields to avoid Angular parsing issues
  $scope.form = {
    sessionId: null,
    classId: '',
    subjectId: '',
    lecturerId: '',
    roomId: '',
    schoolYearId: 'SY2024',
    weekNo: iso.week,
    weekday: 2,
    startTime: null, // Will be set after initialization
    endTime: null,   // Will be set after initialization
    periodFrom: 1,
    periodTo: 3,
    recurrence: 'once',
    status: 'active',
    notes: ''
  };
  $scope.editMode = false;
  $scope.showForm = false;
  $scope.checkingConflicts = false;
  $scope.conflictResult = null;
  
  // Set default time values after initialization to avoid Angular datefmt error
  $timeout(function() {
    if (!$scope.form.startTime || typeof $scope.form.startTime !== 'string') {
      $scope.form.startTime = '07:00';
    }
    if (!$scope.form.endTime || typeof $scope.form.endTime !== 'string') {
      $scope.form.endTime = '09:00';
    }
  }, 0);
  
  // Helper to pad number with zero
  function padZero(num) {
    return (num < 10 ? '0' : '') + num;
  }
  
  // Watch for time values to ensure they're always strings in "HH:mm" format
  $scope.$watch('form.startTime', function(newVal, oldVal) {
    if (newVal === null || newVal === undefined) return;
    if (typeof newVal !== 'string') {
      // If it's somehow not a string, convert it
      if (newVal instanceof Date) {
        var hours = padZero(newVal.getHours());
        var minutes = padZero(newVal.getMinutes());
        $timeout(function() {
          $scope.form.startTime = hours + ':' + minutes;
        }, 0);
      }
    } else if (newVal.length === 8) {
      // If it's "HH:mm:ss", convert to "HH:mm"
      $timeout(function() {
        $scope.form.startTime = newVal.substring(0, 5);
      }, 0);
    }
  });
  
  $scope.$watch('form.endTime', function(newVal, oldVal) {
    if (newVal === null || newVal === undefined) return;
    if (typeof newVal !== 'string') {
      // If it's somehow not a string, convert it
      if (newVal instanceof Date) {
        var hours = padZero(newVal.getHours());
        var minutes = padZero(newVal.getMinutes());
        $timeout(function() {
          $scope.form.endTime = hours + ':' + minutes;
        }, 0);
      }
    } else if (newVal.length === 8) {
      // If it's "HH:mm:ss", convert to "HH:mm"
      $timeout(function() {
        $scope.form.endTime = newVal.substring(0, 5);
      }, 0);
    }
  });

  // Dropdown data
  $scope.classes = [];
  $scope.subjects = [];
  $scope.lecturers = [];
  $scope.rooms = [];
  $scope.schoolYears = [{ schoolYearId: 'SY2024', schoolYearCode: '2024-2025' }];

  // Class selection
  $scope.selectedClassId = null;
  $scope.selectedClassInfo = null;
  $scope.classSearchText = '';
  $scope.filteredClasses = [];
  $scope.showOnlyActive = true;

  // Timetable grid
  $scope.grid = {};
  $scope.allSessions = [];

  // Load dropdowns
  $scope.loadDropdowns = function() {
    ClassService.getAll().then(function(res) {
      $scope.classes = (res.data && res.data.data) || res.data || [];
      $scope.filterClasses();
  }).catch(function(err) { LoggerService.error('Load classes error', err); });
    
    SubjectService.getAll().then(function(res) {
      $scope.subjects = (res.data && res.data.data) || res.data || [];
  }).catch(function(err) { LoggerService.error('Load subjects error', err); });
    
    LecturerService.getAll().then(function(res) {
      $scope.lecturers = (res.data && res.data.data) || res.data || [];
  }).catch(function(err) { LoggerService.error('Load lecturers error', err); });
    
    TimetableApi.getRooms(null, true).then(function(res) {
      $scope.rooms = (res.data && res.data.data) || res.data || [];
  }).catch(function(err) { LoggerService.error('Load rooms error', err); });
  };

  // Filter classes
  $scope.filterClasses = function() {
    var classesToFilter = $scope.classes;
    
    // Filter theo active status
    if ($scope.showOnlyActive) {
      classesToFilter = classesToFilter.filter(function(c) {
        return c.isActive === true || c.is_active_computed === 1 || c.isActive === 1;
      });
    }
    
    // Filter theo search text
    if (!$scope.classSearchText || $scope.classSearchText.trim() === '') {
      $scope.filteredClasses = classesToFilter;
      return;
    }
    
    var search = $scope.classSearchText.toLowerCase().trim();
    $scope.filteredClasses = classesToFilter.filter(function(c) {
      var codeMatch = c.classCode && c.classCode.toLowerCase().includes(search);
      var nameMatch = c.className && c.className.toLowerCase().includes(search);
      var subjectMatch = c.subjectName && c.subjectName.toLowerCase().includes(search);
      var lecturerMatch = c.lecturerName && c.lecturerName.toLowerCase().includes(search);
      return codeMatch || nameMatch || subjectMatch || lecturerMatch;
    });
  };

  // Auto filter khi search text thay đổi
  $scope.$watch('classSearchText', function() {
    $scope.filterClasses();
  });

  // Filter khi load classes
  $scope.$watch('classes', function() {
    $scope.filterClasses();
  }, true);

  // Watch showOnlyActive
  $scope.$watch('showOnlyActive', function() {
    $scope.filterClasses();
  });

  // Helper function để format text hiển thị lớp ngắn gọn
  $scope.getClassDisplayText = function(c) {
    if (!c) return '';
    var code = c.classCode || c.class_code || '';
    var name = c.className || c.class_name || '';
    var display = code + ' - ' + name;
    
    // Giới hạn độ dài tối đa 60 ký tự
    if (display.length > 60) {
      display = display.substring(0, 57) + '...';
    }
    
    // Thêm trạng thái nếu không active
    if (!(c.isActive || c.is_active_computed || c.isActive === 1)) {
      display += ' (Đã tắt)';
    }
    
    return display;
  };
  
  // Helper function để tạo title đầy đủ cho tooltip
  $scope.getClassFullTitle = function(c) {
    if (!c) return '';
    var parts = [];
    var code = c.classCode || c.class_code || '';
    var name = c.className || c.class_name || '';
    if (code || name) {
      parts.push(code + ' - ' + name);
    }
    if (c.subjectName || c.subject_name) {
      parts.push(c.subjectName || c.subject_name);
    }
    if (c.lecturerName || c.lecturer_name) {
      parts.push('GV: ' + (c.lecturerName || c.lecturer_name));
    }
    if (c.semester) {
      parts.push('HK' + c.semester);
    }
    return parts.join(' | ');
  };

  // Class selection handler
  $scope.onClassChange = function() {
    if (!$scope.selectedClassId) {
      $scope.selectedClassInfo = null;
      $scope.loadSessions();
      return;
    }
    
    var selectedClass = $scope.classes.find(function(c) {
      return c.classId === $scope.selectedClassId || c.class_id === $scope.selectedClassId;
    });
    
    if (selectedClass) {
      $scope.selectedClassInfo = {
        classId: selectedClass.classId || selectedClass.class_id,
        classCode: selectedClass.classCode || selectedClass.class_code,
        className: selectedClass.className || selectedClass.class_name,
        subjectName: selectedClass.subjectName || selectedClass.subject_name,
        lecturerName: selectedClass.lecturerName || selectedClass.lecturer_name,
        semester: selectedClass.semester,
        isActive: selectedClass.isActive || selectedClass.is_active_computed || selectedClass.isActive === 1
      };
    }
    
    $scope.loadSessions();
  };

  // Load sessions for current week
  $scope.loadSessions = function() {
    $scope.loading = true;
    $scope.error = null;
    
    var apiCall;
    if ($scope.selectedClassId) {
      apiCall = TimetableApi.getSessionsByClass($scope.selectedClassId, $scope.week);
    } else {
      apiCall = TimetableApi.getAllSessionsByWeek($scope.year, $scope.week);
    }
    
    apiCall.then(function(res) {
      var data = (res.data && res.data.data) || [];
      $scope.allSessions = data;
      // Map theo weekday để hiển thị grid
      var map = {};
      $scope.days.forEach(function(d) { map[d] = []; });
      data.forEach(function(s) {
        if(s.weekday >= 1 && s.weekday <= 7) {
          map[s.weekday].push(s);
        }
      });
      $scope.grid = map;
    }).catch(function(err) {
      $scope.error = 'Lỗi tải danh sách phiên: ' + (err.data && err.data.message) || err.statusText;
      LoggerService.error('Load sessions error', err);
    }).finally(function() {
      $scope.loading = false;
    });
  };

  // Check conflicts
  $scope.checkConflicts = function() {
    if (!$scope.form.classId || !$scope.form.subjectId || !$scope.form.weekday || !$scope.form.startTime || !$scope.form.endTime) {
      ToastService.warning('Vui lòng điền đầy đủ thông tin');
      return;
    }
    
    // Validate time format
    var startTimeStr = timeToApi($scope.form.startTime);
    var endTimeStr = timeToApi($scope.form.endTime);
    if (!startTimeStr || !endTimeStr) {
      ToastService.warning('Định dạng giờ không hợp lệ (cần HH:mm)');
      return;
    }
    
    $scope.checkingConflicts = true;
    $scope.conflictResult = null;
    
    var input = {
      sessionId: $scope.editMode ? $scope.form.sessionId : null,
      classId: $scope.form.classId || '',
      subjectId: $scope.form.subjectId || '',
      lecturerId: $scope.form.lecturerId || null,
      roomId: $scope.form.roomId || null,
      schoolYearId: $scope.form.schoolYearId || null,
      weekNo: parseInt($scope.form.weekNo) || null,
      weekday: parseInt($scope.form.weekday) || 1,
      startTime: startTimeStr, // "HH:mm:ss" format
      endTime: endTimeStr       // "HH:mm:ss" format
    };
    
    LoggerService.debug('Check conflicts input', input);
    
    TimetableApi.checkConflicts(input).then(function(res) {
      $scope.conflictResult = res.data.data || res.data;
      $scope.checkingConflicts = false;
      if ($scope.conflictResult.lecturerConflicts.length === 0 && 
          $scope.conflictResult.roomConflicts.length === 0 && 
          $scope.conflictResult.studentConflicts.length === 0 &&
          !$scope.conflictResult.isOverCapacity) {
        ToastService.success('Không có xung đột, có thể tạo phiên học');
      } else {
        ToastService.warning('Phát hiện xung đột, xem chi tiết bên dưới');
      }
    }).catch(function(err) {
      $scope.checkingConflicts = false;
      var errorMsg = 'Lỗi kiểm tra xung đột';
      if (err.data) {
        if (err.data.message) errorMsg += ': ' + err.data.message;
        if (err.data.errors) {
          var validationErrors = [];
          for (var key in err.data.errors) {
            if (err.data.errors.hasOwnProperty(key)) {
              validationErrors.push(key + ': ' + err.data.errors[key].join(', '));
            }
          }
          if (validationErrors.length > 0) {
            errorMsg += '\n' + validationErrors.join('\n');
          }
        }
      } else if (err.statusText) {
        errorMsg += ': ' + err.statusText;
      }
      ToastService.error(errorMsg);
      LoggerService.error('Check conflicts error', err);
      if (err && err.data) {
        LoggerService.debug('Check conflicts error payload', err.data);
      }
    });
  };

  // Create session
  $scope.createSession = function() {
    // Check class is active
    if ($scope.selectedClassInfo && !$scope.selectedClassInfo.isActive) {
      ToastService.error('Không thể tạo phiên học cho lớp đã bị vô hiệu hóa');
      return;
    }
    
    if ($scope.form.classId) {
      var formClass = $scope.classes.find(function(c) {
        return (c.classId === $scope.form.classId || c.class_id === $scope.form.classId);
      });
      if (formClass && !(formClass.isActive || formClass.is_active_computed || formClass.isActive === 1)) {
        ToastService.error('Không thể tạo phiên học cho lớp đã bị vô hiệu hóa');
        return;
      }
    }
    if (!$scope.conflictResult || $scope.conflictResult.lecturerConflicts.length > 0 || 
        $scope.conflictResult.roomConflicts.length > 0 || $scope.conflictResult.isOverCapacity) {
      ToastService.warning('Vui lòng kiểm tra xung đột trước');
      return;
    }
    
    $scope.loading = true;
    var input = {
      classId: $scope.form.classId,
      subjectId: $scope.form.subjectId,
      lecturerId: $scope.form.lecturerId || null,
      roomId: $scope.form.roomId || null,
      schoolYearId: $scope.form.schoolYearId,
      weekNo: parseInt($scope.form.weekNo),
      weekday: parseInt($scope.form.weekday),
      startTime: timeToApi($scope.form.startTime), // Convert "HH:mm" -> "HH:mm:ss"
      endTime: timeToApi($scope.form.endTime),     // Convert "HH:mm" -> "HH:mm:ss"
      periodFrom: parseInt($scope.form.periodFrom),
      periodTo: parseInt($scope.form.periodTo),
      recurrence: $scope.form.recurrence,
      status: $scope.form.status,
      notes: $scope.form.notes || null,
      actor: $scope.currentUser.username || 'admin'
    };
    
    TimetableApi.createSession(input).then(function(res) {
      ToastService.success('Tạo phiên học thành công');
      $scope.resetForm();
      $scope.loadSessions(); // Reload danh sách
    }).catch(function(err) {
      if (err.status === 409) {
        ToastService.error('Xung đột lịch: ' + (err.data && err.data.message) || 'Conflict');
        $scope.conflictResult = err.data.data || null;
      } else if (err.status === 400) {
        ToastService.error('Lỗi dữ liệu: ' + (err.data && err.data.message) || 'Bad Request');
      } else {
        ToastService.error('Lỗi tạo phiên: ' + (err.data && err.data.message) || err.statusText);
      }
      LoggerService.error('Create session error', err);
    }).finally(function() { $scope.loading = false; });
  };

  // Update session
  $scope.updateSession = function() {
    if (!$scope.form.sessionId) return;
    
    $scope.loading = true;
    var input = {
      classId: $scope.form.classId,
      subjectId: $scope.form.subjectId,
      lecturerId: $scope.form.lecturerId || null,
      roomId: $scope.form.roomId || null,
      schoolYearId: $scope.form.schoolYearId,
      weekNo: parseInt($scope.form.weekNo),
      weekday: parseInt($scope.form.weekday),
      startTime: timeToApi($scope.form.startTime), // Convert "HH:mm" -> "HH:mm:ss"
      endTime: timeToApi($scope.form.endTime),     // Convert "HH:mm" -> "HH:mm:ss"
      periodFrom: parseInt($scope.form.periodFrom),
      periodTo: parseInt($scope.form.periodTo),
      recurrence: $scope.form.recurrence,
      status: $scope.form.status,
      notes: $scope.form.notes || null,
      actor: $scope.currentUser.username || 'admin'
    };
    
    TimetableApi.updateSession($scope.form.sessionId, input).then(function(res) {
      ToastService.success('Cập nhật phiên học thành công');
      $scope.resetForm();
      $scope.loadSessions(); // Reload danh sách
    }).catch(function(err) {
      if (err.status === 409) {
        ToastService.error('Xung đột lịch: ' + (err.data && err.data.message) || 'Conflict');
      } else if (err.status === 400) {
        ToastService.error('Lỗi dữ liệu: ' + (err.data && err.data.message) || 'Bad Request');
      } else {
        ToastService.error('Lỗi cập nhật: ' + (err.data && err.data.message) || err.statusText);
      }
      LoggerService.error('Update session error', err);
    }).finally(function() { $scope.loading = false; });
  };

  // Delete session
  $scope.deleteSession = function(sessionId) {
    if (!confirm('Bạn có chắc muốn xóa phiên học này?')) return;
    
    TimetableApi.deleteSession(sessionId).then(function(res) {
      ToastService.success('Xóa phiên học thành công');
      $scope.loadSessions(); // Reload danh sách
    }).catch(function(err) {
      ToastService.error('Lỗi xóa phiên: ' + (err.data && err.data.message) || err.statusText);
      LoggerService.error('Delete session error', err);
    });
  };

  // Reset form
  $scope.resetForm = function() {
    $scope.editMode = false;
    $scope.showForm = false;
    $scope.conflictResult = null;
    
    $scope.form.sessionId = null;
    $scope.form.classId = '';
    $scope.form.subjectId = '';
    $scope.form.lecturerId = '';
    $scope.form.roomId = '';
    $scope.form.schoolYearId = 'SY2024';
    $scope.form.weekNo = $scope.week;
    $scope.form.weekday = 2;
    $scope.form.periodFrom = 1;
    $scope.form.periodTo = 3;
    $scope.form.recurrence = 'once';
    $scope.form.status = 'active';
    $scope.form.notes = '';
    
    // Set time values after a short delay to avoid Angular parsing issues
    $timeout(function() {
      $scope.form.startTime = '07:00'; // Format cho input type="time"
      $scope.form.endTime = '09:00';   // Format cho input type="time"
    }, 10);
  };

  // Open form to create
  $scope.openCreateForm = function() {
    $scope.resetForm();
    $scope.showForm = true;
  };

  // Open form to edit
  $scope.openEditForm = function(session) {
    $scope.editMode = true;
    $scope.showForm = true;
    $scope.conflictResult = null;
    
    // Set form values, using $timeout to avoid Angular datefmt error
    $scope.form.sessionId = session.sessionId;
    $scope.form.classId = session.classId;
    $scope.form.subjectId = session.subjectId;
    $scope.form.lecturerId = session.lecturerId || '';
    $scope.form.roomId = session.roomId || '';
    $scope.form.schoolYearId = session.schoolYearId;
    $scope.form.weekNo = session.weekNo;
    $scope.form.weekday = session.weekday;
    $scope.form.periodFrom = session.periodFrom;
    $scope.form.periodTo = session.periodTo;
    $scope.form.recurrence = session.recurrence || 'once';
    $scope.form.status = session.status;
    $scope.form.notes = session.notes || '';
    
    // Set time values after a short delay to avoid parsing issues
    $timeout(function() {
      var start = timeToInput(session.startTime);
      var end = timeToInput(session.endTime);
      if (start && typeof start === 'string') $scope.form.startTime = start;
      if (end && typeof end === 'string') $scope.form.endTime = end;
    }, 10);
  };

  // Week navigation
  $scope.prevWeek = function() {
    $scope.week = $scope.week - 1;
    if ($scope.week < 1) {
      $scope.week = 53;
      $scope.year = $scope.year - 1;
    }
    $scope.form.weekNo = $scope.week;
    $scope.loadSessions();
  };
  
  $scope.nextWeek = function() {
    $scope.week = $scope.week + 1;
    if ($scope.week > 53) {
      $scope.week = 1;
      $scope.year = $scope.year + 1;
    }
    $scope.form.weekNo = $scope.week;
    $scope.loadSessions();
  };

  // Initialize
  $scope.loadDropdowns();
  $scope.loadSessions();
}]);

