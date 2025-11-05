// Schedule Service
app.service('ScheduleService', ['ApiService', function(ApiService) {
    
    /**
     * Get all schedules
     */
    this.getAll = function() {
        return ApiService.get('/schedules');
    };
    
    /**
     * Get schedule by ID
     */
    this.getById = function(scheduleId) {
        return ApiService.get('/schedules/' + scheduleId);
    };
    
    /**
     * Get schedules by class ID
     */
    this.getByClass = function(classId) {
        return ApiService.get('/schedules/class/' + classId);
    };
    
    /**
     * Get schedule by class ID and date
     * Finds the schedule that matches the class and date
     */
    this.getByClassAndDate = function(classId, date) {
        return this.getByClass(classId).then(function(response) {
            var schedules = response.data?.data || response.data || [];
            
            if (!date) {
                return { data: schedules[0] || null }; // Return first schedule if no date
            }
            
            // Parse date
            var targetDate = new Date(date);
            if (isNaN(targetDate.getTime())) {
                return { data: null };
            }
            
            var targetDayOfWeek = targetDate.getDay(); // 0 = Sunday, 1 = Monday, etc.
            var dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
            var targetDayName = dayNames[targetDayOfWeek];
            
            // Find schedule that matches the day of week and date
            var matchingSchedule = schedules.find(function(schedule) {
                var scheduleDate = new Date(schedule.startTime || schedule.start_time);
                var scheduleDayOfWeek = schedule.dayOfWeek || schedule.day_of_week;
                
                // Check if day of week matches
                if (scheduleDayOfWeek) {
                    var dayMatch = scheduleDayOfWeek.toLowerCase() === targetDayName.toLowerCase() ||
                                  scheduleDayOfWeek.toLowerCase().includes(targetDayName.toLowerCase().substring(0, 3));
                    if (dayMatch) {
                        // Check if the date is within the schedule's time range
                        var scheduleStart = new Date(scheduleDate);
                        scheduleStart.setHours(0, 0, 0, 0);
                        var targetStart = new Date(targetDate);
                        targetStart.setHours(0, 0, 0, 0);
                        
                        return scheduleStart.getTime() <= targetStart.getTime();
                    }
                }
                
                // Fallback: check if date matches
                var scheduleDateOnly = new Date(scheduleDate);
                scheduleDateOnly.setHours(0, 0, 0, 0);
                var targetDateOnly = new Date(targetDate);
                targetDateOnly.setHours(0, 0, 0, 0);
                
                return scheduleDateOnly.getTime() === targetDateOnly.getTime();
            });
            
            return { data: matchingSchedule || schedules[0] || null };
        });
    };
}]);

