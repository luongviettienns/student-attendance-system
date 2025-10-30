// Registration Period Service
app.service('RegistrationPeriodService', ['ApiService', function(ApiService) {
    
    // ============================================================
    // 1️⃣ GET ALL
    // ============================================================
    this.getAll = function() {
        return ApiService.get('/registration-periods');
    };
    
    // ============================================================
    // 2️⃣ GET ACTIVE PERIOD
    // ============================================================
    this.getActive = function() {
        return ApiService.get('/registration-periods/active');
    };
    
    // ============================================================
    // 3️⃣ GET BY ID
    // ============================================================
    this.getById = function(id) {
        return ApiService.get('/registration-periods/' + id);
    };
    
    // ============================================================
    // 4️⃣ CREATE
    // ============================================================
    this.create = function(period) {
        return ApiService.post('/registration-periods', period);
    };
    
    // ============================================================
    // 5️⃣ UPDATE
    // ============================================================
    this.update = function(id, period) {
        return ApiService.put('/registration-periods/' + id, period);
    };
    
    // ============================================================
    // 6️⃣ DELETE
    // ============================================================
    this.delete = function(id) {
        return ApiService.delete('/registration-periods/' + id);
    };
    
    // ============================================================
    // 7️⃣ OPEN PERIOD
    // ============================================================
    this.open = function(id) {
        return ApiService.post('/registration-periods/' + id + '/open');
    };
    
    // ============================================================
    // 8️⃣ CLOSE PERIOD
    // ============================================================
    this.close = function(id) {
        return ApiService.post('/registration-periods/' + id + '/close');
    };
}]);

