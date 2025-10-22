// Student Grades Controller
app.controller('StudentGradesController', ['$scope', 'AuthService', function($scope, AuthService) {
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.selectedYear = '';
    $scope.selectedSemester = '';
    
    // GPA Summary
    $scope.summary = {
        currentGPA: 3.45,
        cumulativeGPA: 3.38,
        totalCredits: 98,
        requiredCredits: 120,
        rank: 'Giỏi'
    };
    
    // Demo semesters with grades
    $scope.semesters = [
        {
            name: 'Học kỳ 1 - Năm học 2023-2024',
            year: '2023-2024',
            semester: '1',
            gpa: 3.52,
            credits: 18,
            grades: [
                {
                    subjectCode: 'IT301',
                    subjectName: 'Lập trình Web',
                    credits: 3,
                    attendance: 9.0,
                    assignment: 8.5,
                    midterm: 8.0,
                    final: 8.5,
                    total: 8.4,
                    letter: 'A'
                },
                {
                    subjectCode: 'IT302',
                    subjectName: 'Cơ sở dữ liệu',
                    credits: 3,
                    attendance: 10.0,
                    assignment: 9.0,
                    midterm: 8.5,
                    final: 9.0,
                    total: 8.9,
                    letter: 'A'
                },
                {
                    subjectCode: 'IT303',
                    subjectName: 'Kiến trúc máy tính',
                    credits: 3,
                    attendance: 8.0,
                    assignment: 7.5,
                    midterm: 7.0,
                    final: 7.5,
                    total: 7.4,
                    letter: 'B+'
                },
                {
                    subjectCode: 'MA201',
                    subjectName: 'Toán rời rạc',
                    credits: 3,
                    attendance: 9.0,
                    assignment: 8.0,
                    midterm: 8.5,
                    final: 8.0,
                    total: 8.2,
                    letter: 'A'
                },
                {
                    subjectCode: 'EN201',
                    subjectName: 'Tiếng Anh chuyên ngành',
                    credits: 3,
                    attendance: 10.0,
                    assignment: 9.5,
                    midterm: 9.0,
                    final: 9.5,
                    total: 9.4,
                    letter: 'A'
                },
                {
                    subjectCode: 'PE201',
                    subjectName: 'Giáo dục thể chất',
                    credits: 3,
                    attendance: 10.0,
                    assignment: null,
                    midterm: null,
                    final: 8.0,
                    total: 8.4,
                    letter: 'A'
                }
            ]
        },
        {
            name: 'Học kỳ 2 - Năm học 2022-2023',
            year: '2022-2023',
            semester: '2',
            gpa: 3.28,
            credits: 18,
            grades: [
                {
                    subjectCode: 'IT201',
                    subjectName: 'Cấu trúc dữ liệu và giải thuật',
                    credits: 3,
                    attendance: 8.0,
                    assignment: 7.5,
                    midterm: 7.0,
                    final: 7.5,
                    total: 7.4,
                    letter: 'B+'
                },
                {
                    subjectCode: 'IT202',
                    subjectName: 'Lập trình hướng đối tượng',
                    credits: 3,
                    attendance: 9.0,
                    assignment: 8.5,
                    midterm: 8.0,
                    final: 8.5,
                    total: 8.4,
                    letter: 'A'
                },
                {
                    subjectCode: 'IT203',
                    subjectName: 'Hệ điều hành',
                    credits: 3,
                    attendance: 7.0,
                    assignment: 6.5,
                    midterm: 6.0,
                    final: 6.5,
                    total: 6.4,
                    letter: 'C+'
                },
                {
                    subjectCode: 'IT204',
                    subjectName: 'Mạng máy tính',
                    credits: 3,
                    attendance: 8.0,
                    assignment: 7.5,
                    midterm: 8.0,
                    final: 8.0,
                    total: 7.9,
                    letter: 'B+'
                },
                {
                    subjectCode: 'MA101',
                    subjectName: 'Xác suất thống kê',
                    credits: 3,
                    attendance: 7.5,
                    assignment: 7.0,
                    midterm: 7.5,
                    final: 7.0,
                    total: 7.2,
                    letter: 'B+'
                },
                {
                    subjectCode: 'PE101',
                    subjectName: 'Giáo dục thể chất',
                    credits: 3,
                    attendance: 10.0,
                    assignment: null,
                    midterm: null,
                    final: 8.5,
                    total: 8.8,
                    letter: 'A'
                }
            ]
        }
    ];
}]);

