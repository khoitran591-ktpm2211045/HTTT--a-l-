// Global variables for admin page
let currentSchools = [];
let schoolsTable;
let editingSchoolId = null;

// Initialize the admin application
document.addEventListener('DOMContentLoaded', function() {
    loadAllSchools();
    setupEventListeners();
});

// Initialize DataTable
function initializeDataTable() {
    schoolsTable = $('#schoolsTable').DataTable({
        language: {
            url: 'https://cdn.datatables.net/plug-ins/1.13.7/i18n/vi.json'
        },
        responsive: true,
        pageLength: 25,
        order: [[0, 'asc']],
        columnDefs: [
            { orderable: false, targets: [7] } // Disable sorting on actions column
        ]
    });
}

// Setup event listeners
function setupEventListeners() {
    // Level filter
    document.getElementById('levelFilter').addEventListener('change', function() {
        filterTable();
    });
    
    // District filter
    document.getElementById('districtFilter').addEventListener('change', function() {
        filterTable();
    });
    
    // Search input
    document.getElementById('searchInput').addEventListener('input', function() {
        schoolsTable.search(this.value).draw();
    });
}

// Load all schools
async function loadAllSchools() {
    try {
        showLoading();
        const response = await fetch('api/schools.php?action=get_all');
        const data = await response.json();
        
        if (data.success) {
            currentSchools = data.data;
            displaySchoolsInTable(currentSchools);
            // updateStatistics(); // Removed - using API data instead
            populateDistrictFilter();
        } else {
            showError('Lỗi tải dữ liệu: ' + data.error);
        }
    } catch (error) {
        showError('Lỗi kết nối: ' + error.message);
    }
}

// Function to get proper school name from school code
function getSchoolName(schoolCode) {
    const schoolNames = {
        'MN004': 'ACA - Mầm non song ngữ',
        'CDCT001': 'Cao đẳng Cần Thơ',
        'CDCT002': 'Cao đẳng Y tế Cần Thơ',
        'CDCT003': 'Cao đẳng Kinh tế - Kỹ thuật Cần Thơ',
        'CDCT004': 'Cao đẳng Kinh tế Đối ngoại (Cơ sở Cần Thơ)',
        'CDCT005': 'Cao đẳng FPT Polytechnic (Cơ sở Cần Thơ)',
        'CDCT006': 'Cao đẳng Công nghệ Thông tin Cần Thơ',
        'CDCT007': 'Cao đẳng Nghề Cần Thơ',
        'CDCT008': 'Cao đẳng Du lịch Cần Thơ',
        'CDCT009': 'Cao đẳng Nông nghiệp Cần Thơ',
        'CDCT010': 'Cao đẳng Giao thông Vận tải Cần Thơ',
        'CDCT011': 'Cao đẳng Xây dựng Cần Thơ'
    };
    
    return schoolNames[schoolCode] || schoolCode;
}

// Display schools in table
function displaySchoolsInTable(schools) {
    const tbody = document.getElementById('schoolsTableBody');
    
    if (schools.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="8" class="text-center">Không có dữ liệu</td>
            </tr>
        `;
        // Initialize DataTable if not already initialized
        if (!schoolsTable) {
            initializeDataTable();
        }
        return;
    }
    
    let html = '';
    schools.forEach(school => {
        const statusBadge = getStatusBadge(school.trang_thai);
        html += `
            <tr>
                <td>${getSchoolName(school.ten_truong)}</td>
                <td><span class="badge bg-info">${school.ten_cap_hoc}</span></td>
                <td>${school.ten_loai_truong}</td>
                <td>${school.ten_quan_huyen}</td>
                <td class="text-center">${school.so_lop}</td>
                <td class="text-center">${school.so_hoc_sinh.toLocaleString()}</td>
                <td>${statusBadge}</td>
                <td>
                    <div class="btn-group" role="group">
                        <button class="btn btn-warning btn-sm" onclick="editSchool('${school.id}')" title="Chỉnh sửa">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-danger btn-sm" onclick="deleteSchool('${school.id}')" title="Xóa">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `;
    });
    
    tbody.innerHTML = html;
    
    // Initialize DataTable if not already initialized
    if (!schoolsTable) {
        initializeDataTable();
    } else {
        // Update existing DataTable
        schoolsTable.clear();
        schoolsTable.rows.add($(tbody).find('tr'));
        schoolsTable.draw();
    }
}

// Get status badge
function getStatusBadge(status) {
    const badges = {
        'Hoạt động': '<span class="badge bg-success">Hoạt động</span>',
        'Tạm dừng': '<span class="badge bg-warning">Tạm dừng</span>',
        'Đóng cửa': '<span class="badge bg-danger">Đóng cửa</span>'
    };
    return badges[status] || '<span class="badge bg-secondary">' + status + '</span>';
}

// Filter table
async function filterTable() {
    const levelFilter = document.getElementById('levelFilter').value;
    const districtFilter = document.getElementById('districtFilter').value;
    
    try {
        showLoading();
        
        // Nếu có bộ lọc cấp học, gọi API để lấy dữ liệu theo cấp học
        if (levelFilter) {
            const response = await fetch(`api/schools.php?action=get_by_level&level=${levelFilter}`);
            const data = await response.json();
            
            if (data.success) {
                currentSchools = data.data;
            } else {
                showError('Lỗi tải dữ liệu: ' + data.error);
                return;
            }
        } else {
            // Nếu không có bộ lọc cấp học, tải tất cả dữ liệu
            const response = await fetch('api/schools.php?action=get_all');
            const data = await response.json();
            
            if (data.success) {
                currentSchools = data.data;
            } else {
                showError('Lỗi tải dữ liệu: ' + data.error);
                return;
            }
        }
        
        // Lọc theo quận/huyện nếu có
        let filteredSchools = currentSchools;
        if (districtFilter) {
            filteredSchools = filteredSchools.filter(school => school.ten_quan_huyen === districtFilter);
        }
        
        displaySchoolsInTable(filteredSchools);
        
    } catch (error) {
        showError('Lỗi kết nối: ' + error.message);
    }
}




// Populate district filter
function populateDistrictFilter() {
    const districts = [...new Set(currentSchools.map(school => school.ten_quan_huyen))];
    const select = document.getElementById('districtFilter');
    
    // Clear existing options except the first one
    select.innerHTML = '<option value="">Tất cả quận/huyện</option>';
    
    districts.forEach(district => {
        const option = document.createElement('option');
        option.value = district;
        option.textContent = district;
        select.appendChild(option);
    });
}

// Validate coordinates
async function validateCoordinates() {
    const lng = document.getElementById('schoolLongitude').value;
    const lat = document.getElementById('schoolLatitude').value;
    
    if (!lng || !lat) {
        document.getElementById('coordinateValidation').innerHTML = 
            '<div class="text-warning"><i class="fas fa-exclamation-triangle me-1"></i>Vui lòng nhập tọa độ</div>';
        return;
    }
    
    try {
        const response = await fetch(`api/schools.php?action=validate_coordinates&longitude=${lng}&latitude=${lat}`);
        const data = await response.json();
        
        if (data.success) {
            const validationDiv = document.getElementById('coordinateValidation');
            if (data.is_valid) {
                validationDiv.innerHTML = 
                    '<div class="text-success"><i class="fas fa-check-circle me-1"></i>' + data.message + '</div>';
            } else {
                validationDiv.innerHTML = 
                    '<div class="text-danger"><i class="fas fa-times-circle me-1"></i>' + data.message + '</div>';
            }
        }
    } catch (error) {
        document.getElementById('coordinateValidation').innerHTML = 
            '<div class="text-danger"><i class="fas fa-exclamation-triangle me-1"></i>Lỗi kiểm tra tọa độ</div>';
    }
}

// Add new school
async function addSchool() {
    const form = document.getElementById('addSchoolForm');
    
    // Validate required fields
    const requiredFields = ['schoolName', 'schoolLevel', 'schoolType', 'schoolDistrict', 'schoolAddress', 'schoolLongitude', 'schoolLatitude'];
    for (let field of requiredFields) {
        if (!document.getElementById(field).value) {
            showError(`Vui lòng điền đầy đủ thông tin: ${field}`);
            return;
        }
    }
    
    // Prepare data
    const schoolData = {
        ten_truong: document.getElementById('schoolName').value,
        ma_cap_hoc: document.getElementById('schoolLevel').value,
        ma_loai_truong: document.getElementById('schoolType').value,
        ma_quan_huyen: document.getElementById('schoolDistrict').value,
        dia_chi: document.getElementById('schoolAddress').value,
        longitude: parseFloat(document.getElementById('schoolLongitude').value),
        latitude: parseFloat(document.getElementById('schoolLatitude').value),
        so_hoc_sinh: parseInt(document.getElementById('schoolStudents').value) || 0,
        so_lop: parseInt(document.getElementById('schoolClasses').value) || 0,
        dien_thoai: document.getElementById('schoolPhone').value,
        email: document.getElementById('schoolEmail').value,
        nam_thanh_lap: new Date().getFullYear(),
        dien_tich_khuon_vien: 0
    };
    
    try {
        const response = await fetch('api/schools.php?action=add_school', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(schoolData)
        });
        
        const data = await response.json();
        
        if (data.success) {
            showSuccess('Thêm trường học thành công!');
            document.getElementById('addSchoolModal').querySelector('.btn-close').click();
            form.reset();
            loadAllSchools();
        } else {
            showError('Lỗi thêm trường học: ' + data.error);
        }
    } catch (error) {
        showError('Lỗi kết nối: ' + error.message);
    }
}

// Edit school
function editSchool(schoolId) {
    const school = currentSchools.find(s => s.id === schoolId);
    if (!school) {
        showError('Không tìm thấy trường học');
        return;
    }
    
    editingSchoolId = schoolId;
    
    // Populate edit form
    document.getElementById('editSchoolId').value = school.id;
    document.getElementById('editSchoolName').value = school.ten_truong;
    document.getElementById('editSchoolLevel').value = school.ma_cap_hoc;
    document.getElementById('editSchoolType').value = school.ma_loai_truong;
    document.getElementById('editSchoolDistrict').value = school.ma_quan_huyen;
    document.getElementById('editSchoolAddress').value = school.dia_chi;
    document.getElementById('editSchoolLongitude').value = school.longitude;
    document.getElementById('editSchoolLatitude').value = school.latitude;
    document.getElementById('editSchoolStudents').value = school.so_hoc_sinh;
    document.getElementById('editSchoolClasses').value = school.so_lop;
    document.getElementById('editSchoolPhone').value = school.dien_thoai || '';
    document.getElementById('editSchoolEmail').value = school.email || '';
    document.getElementById('editSchoolStatus').value = school.trang_thai;
    
    // Show modal
    const modal = new bootstrap.Modal(document.getElementById('editSchoolModal'));
    modal.show();
}

// Update school
async function updateSchool() {
    if (!editingSchoolId) {
        showError('Không có trường học để cập nhật');
        return;
    }
    
    // Validate required fields
    const requiredFields = ['editSchoolName', 'editSchoolLevel', 'editSchoolType', 'editSchoolDistrict', 'editSchoolAddress', 'editSchoolLongitude', 'editSchoolLatitude'];
    for (let field of requiredFields) {
        if (!document.getElementById(field).value) {
            showError(`Vui lòng điền đầy đủ thông tin: ${field}`);
            return;
        }
    }
    
    // Prepare data as FormData
    const formData = new FormData();
    formData.append('id', editingSchoolId);
    formData.append('ten_truong', document.getElementById('editSchoolName').value);
    formData.append('ma_cap_hoc', document.getElementById('editSchoolLevel').value);
    formData.append('ma_loai_truong', document.getElementById('editSchoolType').value);
    formData.append('ma_quan_huyen', document.getElementById('editSchoolDistrict').value);
    formData.append('dia_chi', document.getElementById('editSchoolAddress').value);
    formData.append('longitude', document.getElementById('editSchoolLongitude').value);
    formData.append('latitude', document.getElementById('editSchoolLatitude').value);
    formData.append('so_hoc_sinh', document.getElementById('editSchoolStudents').value || 0);
    formData.append('so_lop', document.getElementById('editSchoolClasses').value || 0);
    formData.append('dien_thoai', document.getElementById('editSchoolPhone').value);
    formData.append('email', document.getElementById('editSchoolEmail').value);
    formData.append('trang_thai', document.getElementById('editSchoolStatus').value);
    
    try {
        const response = await fetch('api/schools.php?action=update', {
            method: 'POST',
            body: formData
        });
        
        const data = await response.json();
        
        if (data.success) {
            showSuccess('Cập nhật trường học thành công!');
            document.getElementById('editSchoolModal').querySelector('.btn-close').click();
            loadAllSchools();
            editingSchoolId = null;
        } else {
            showError('Lỗi cập nhật trường học: ' + data.error);
        }
    } catch (error) {
        showError('Lỗi kết nối: ' + error.message);
    }
}

// Delete school
async function deleteSchool(schoolId) {
    if (!confirm('Bạn có chắc chắn muốn xóa trường học này?')) {
        return;
    }
    
    try {
        const response = await fetch('api/schools.php?action=delete_school', {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ id: schoolId })
        });
        
        const data = await response.json();
        
        if (data.success) {
            showSuccess('Xóa trường học thành công!');
            loadAllSchools();
        } else {
            showError('Lỗi xóa trường học: ' + data.error);
        }
    } catch (error) {
        showError('Lỗi kết nối: ' + error.message);
    }
}

// Utility functions
function showLoading() {
    const tbody = document.getElementById('schoolsTableBody');
    tbody.innerHTML = `
        <tr>
            <td colspan="8" class="text-center">
                <div class="loading">
                    <div class="spinner-border" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-2">Đang tải dữ liệu...</p>
                </div>
            </td>
        </tr>
    `;
    
    // Destroy existing DataTable if it exists
    if (schoolsTable) {
        schoolsTable.destroy();
        schoolsTable = null;
    }
}

function showError(message) {
    alert('Lỗi: ' + message);
}

function showSuccess(message) {
    alert('Thành công: ' + message);
}

// Export functions for global access
window.loadAllSchools = loadAllSchools;
window.validateCoordinates = validateCoordinates;
window.addSchool = addSchool;
window.editSchool = editSchool;
window.updateSchool = updateSchool;
window.deleteSchool = deleteSchool;
