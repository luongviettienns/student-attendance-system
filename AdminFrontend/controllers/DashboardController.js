// Dashboard Controller
app.controller('DashboardController', ['$scope', '$q', 'AuthService', 'UserService', 'FacultyService', 'StudentService', 'SubjectService', 'LecturerService', 'MajorService', 'AcademicYearService', 'AvatarService',
    function($scope, $q, AuthService, UserService, FacultyService, StudentService, SubjectService, LecturerService, MajorService, AcademicYearService, AvatarService) {
    
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.stats = {
        totalUsers: 0,
        totalStudents: 0,
        totalLecturers: 0,
        totalFaculties: 0,
        totalMajors: 0,
        totalSubjects: 0,
        totalAcademicYears: 0
    };
    
    $scope.loading = true;
    $scope.error = null;
    
    // Initialize Avatar Modal Functions
    AvatarService.initAvatarModal($scope);
    
    // Helper function to extract count from response
    function getCountFromResponse(response) {
        if (!response || !response.data) return 0;
        
        // Check if it's pagination response
        if (response.data.pagination && response.data.pagination.totalCount) {
            return response.data.pagination.totalCount;
        }
        
        // Check if it's array directly
        if (Array.isArray(response.data)) {
            return response.data.length;
        }
        
        // Check if it's wrapped in data property
        if (response.data.data) {
            if (Array.isArray(response.data.data)) {
                return response.data.data.length;
            }
        }
        
        return 0;
    }
    
    // Load all statistics
    $scope.loadStats = function() {
        $scope.loading = true;
        $scope.error = null;
        
        // Create promises for all API calls
        var promises = {
            users: UserService.getAll().catch(function(err) { 
                console.error('Error loading users:', err);
                return {data: []};
            }),
            students: StudentService.getAll().catch(function(err) { 
                console.error('Error loading students:', err);
                return {data: []};
            }),
            lecturers: LecturerService.getAll().catch(function(err) { 
                console.error('Error loading lecturers:', err);
                return {data: []};
            }),
            faculties: FacultyService.getAll().catch(function(err) { 
                console.error('Error loading faculties:', err);
                return {data: []};
            }),
            majors: MajorService.getAll().catch(function(err) { 
                console.error('Error loading majors:', err);
                return {data: []};
            }),
            subjects: SubjectService.getAll().catch(function(err) { 
                console.error('Error loading subjects:', err);
                return {data: []};
            }),
            academicYears: AcademicYearService.getAll().catch(function(err) { 
                console.error('Error loading academic years:', err);
                return {data: []};
            })
        };
        
        // Wait for all promises to complete
        $q.all(promises).then(function(results) {
            $scope.stats.totalUsers = getCountFromResponse(results.users);
            $scope.stats.totalStudents = getCountFromResponse(results.students);
            $scope.stats.totalLecturers = getCountFromResponse(results.lecturers);
            $scope.stats.totalFaculties = getCountFromResponse(results.faculties);
            $scope.stats.totalMajors = getCountFromResponse(results.majors);
            $scope.stats.totalSubjects = getCountFromResponse(results.subjects);
            $scope.stats.totalAcademicYears = getCountFromResponse(results.academicYears);
            
            console.log('Dashboard stats loaded:', $scope.stats);
            $scope.loading = false;
        }).catch(function(error) {
            console.error('Error loading dashboard stats:', error);
            $scope.error = 'Không thể tải dữ liệu thống kê';
            $scope.loading = false;
        });
    };
    
    // Initialize
    $scope.loadStats();
}]);

