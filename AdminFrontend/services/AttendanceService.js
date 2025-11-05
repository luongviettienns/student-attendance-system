// Attendance Service
app.service('AttendanceService', ['ApiService', function(ApiService) {
    
    /**
     * Get all attendances with optional filters
     * @param {object} params - { classId, studentId, scheduleId, attendanceDate, page, pageSize }
     */
    this.getAll = function(params) {
        params = params || {};
        return ApiService.get('/attendances', params).then(function(response) {
            if (response.data && response.data.data) {
                response.data = response.data.data;
            }
            return response;
        });
    };

    /**
     * Get attendance by ID
     */
    this.getById = function(attendanceId) {
        return ApiService.get('/attendances/' + attendanceId).then(function(response) {
            if (response.data && response.data.data) {
                response.data = response.data.data;
            }
            return response;
        });
    };

    /**
     * Get attendances by class
     */
    this.getByClass = function(classId, attendanceDate) {
        var params = {};
        if (attendanceDate) {
            params.attendanceDate = attendanceDate;
        }
        return ApiService.get('/attendances/class/' + classId, params).then(function(response) {
            if (response.data && response.data.data) {
                response.data = response.data.data;
            }
            return response;
        });
    };

    /**
     * Get attendances by student ID
     */
    this.getByStudent = function(studentId) {
        return ApiService.get('/attendances/student/' + studentId).then(function(response) {
            if (response.data && response.data.data) {
                response.data = response.data.data;
            }
            return response;
        });
    };

    /**
     * Get attendances by schedule ID
     */
    this.getBySchedule = function(scheduleId) {
        return ApiService.get('/attendances/schedule/' + scheduleId).then(function(response) {
            if (response.data && response.data.data) {
                response.data = response.data.data;
            }
            return response;
        });
    };

    /**
     * Create single attendance record
     */
    this.create = function(payload) {
        return ApiService.post('/attendances', payload, {
            invalidateCache: 'attendances:*'
        });
    };

    /**
     * Batch create attendance records
     */
    this.createBatch = function(attendances) {
        return ApiService.post('/attendances/batch', attendances, {
            invalidateCache: 'attendances:*'
        });
    };

    /**
     * Update attendance record
     */
    this.update = function(attendanceId, payload) {
        return ApiService.put('/attendances/' + attendanceId, payload, {
            invalidateCache: 'attendances:*'
        });
    };

    /**
     * Delete attendance record
     */
    this.delete = function(attendanceId, deletedBy) {
        return ApiService.delete('/attendances/' + attendanceId, {
            deletedBy: deletedBy
        }, {
            invalidateCache: 'attendances:*'
        });
    };

    /**
     * Import attendance from Excel
     */
    this.importExcel = function(formData) {
        return ApiService.uploadFile('/attendances/import', formData);
    };

    /**
     * Get attendance statistics (for tạch môn check)
     */
    this.getStatistics = function(classId, studentId) {
        var params = {};
        if (classId) params.classId = classId;
        if (studentId) params.studentId = studentId;
        return ApiService.get('/attendances/statistics', params);
    };
}]);


