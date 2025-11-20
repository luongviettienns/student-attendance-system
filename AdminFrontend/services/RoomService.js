// Room Service
app.service('RoomService', ['ApiService', function(ApiService) {
    
    this.getAll = function(page, pageSize, search, isActive) {
        var params = {
            page: page || 1,
            pageSize: pageSize || 10
        };
        if (search) params.search = search;
        if (isActive !== null && isActive !== undefined) params.isActive = isActive;
        
        return ApiService.get('/rooms', params).then(function(response) {
            // ✅ Backend trả về: { success: true, data: [...], totalCount, page, pageSize, totalPages }
            // Giữ nguyên response.data để controller xử lý
            return response;
        });
    };
    
    this.getById = function(id) {
        return ApiService.get('/rooms/' + id);
    };
    
    this.search = function(search, isActive) {
        var params = {};
        if (search) params.search = search;
        if (isActive !== null && isActive !== undefined) params.isActive = isActive;
        
        return ApiService.get('/rooms/search', params);
    };
    
    this.create = function(room) {
        return ApiService.post('/rooms', room);
    };
    
    this.update = function(id, room) {
        return ApiService.put('/rooms/' + id, room);
    };
    
    this.delete = function(id) {
        return ApiService.delete('/rooms/' + id);
    };
}]);

