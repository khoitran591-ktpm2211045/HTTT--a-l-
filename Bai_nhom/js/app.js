// Global variables
let map;
let schoolMarkers = [];
let currentSchools = [];
// Chart variables removed - not needed on map page

// School level colors
const levelColors = {
    'DH': '#e74c3c',    // Đại học - Đỏ
    'CD': '#f39c12',    // Cao đẳng - Cam
    'THPT': '#27ae60',  // THPT - Xanh lá
    'THCS': '#3498db',  // THCS - Xanh dương
    'TH': '#9b59b6',    // Tiểu học - Tím
    'MN': '#e67e22'     // Mầm non - Cam đậm
};

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    initializeMap();
    loadAllSchools();
    setupEventListeners();
});

// Initialize Leaflet map
function initializeMap() {
    // Center on Can Tho city
    map = L.map('map').setView([10.0337, 105.7809], 11);
    
    // Add OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors',
        maxZoom: 18
    }).addTo(map);
    
    // Add click handler for adding schools
    map.on('click', function(e) {
        const latEl = document.getElementById('schoolLatitude');
        const lngEl = document.getElementById('schoolLongitude');
        
        // Only update coordinates if elements exist (admin page)
        if (latEl && lngEl) {
            latEl.value = e.latlng.lat.toFixed(6);
            lngEl.value = e.latlng.lng.toFixed(6);
            validateCoordinates();
        }
    });
}

// Setup event listeners
function setupEventListeners() {
    // Level filter
    const levelFilter = document.getElementById('levelFilter');
    if (levelFilter) {
        levelFilter.addEventListener('change', function() {
            const level = this.value;
            if (level) {
                loadSchoolsByLevel(level);
            } else {
                loadAllSchools();
            }
        });
    }
    
    // Student filter
    const studentFilter = document.getElementById('studentFilter');
    if (studentFilter) {
        studentFilter.addEventListener('input', function() {
            const minStudents = parseInt(this.value) || 0;
            if (minStudents > 0) {
                searchSchoolsByStudents(minStudents);
            } else {
                loadAllSchools();
            }
        });
    }
    
    // District filter
    const districtFilter = document.getElementById('districtFilter');
    if (districtFilter) {
        districtFilter.addEventListener('change', function() {
            const district = this.value;
            if (district) {
                filterSchoolsByDistrict(district);
            } else {
                loadAllSchools();
            }
        });
    }
}

// Load all schools
async function loadAllSchools() {
    try {
        showLoading();
        const response = await fetch('api/schools.php?action=get_all');
        const data = await response.json();
        
        if (data.success) {
            currentSchools = data.data;
            displaySchoolsOnMap(currentSchools);
            populateDistrictFilter();
        } else {
            showError('Lỗi tải dữ liệu: ' + data.error);
        }
    } catch (error) {
        showError('Lỗi kết nối: ' + error.message);
    }
}

// Load schools by level
async function loadSchoolsByLevel(level) {
    try {
        showLoading();
        const response = await fetch(`api/schools.php?action=get_by_level&level=${level}`);
        const data = await response.json();
        
        if (data.success) {
            currentSchools = data.data;
            displaySchoolsOnMap(currentSchools);
        } else {
            showError('Lỗi tải dữ liệu: ' + data.error);
        }
    } catch (error) {
        showError('Lỗi kết nối: ' + error.message);
    }
}

// Search schools by student count
async function searchSchoolsByStudents(minStudents) {
    try {
        showLoading();
        const response = await fetch(`api/schools.php?action=search_by_students&min_students=${minStudents}`);
        const data = await response.json();
        
        if (data.success) {
            currentSchools = data.data;
            displaySchoolsOnMap(currentSchools);
        } else {
            showError('Lỗi tìm kiếm: ' + data.error);
        }
    } catch (error) {
        showError('Lỗi kết nối: ' + error.message);
    }
}

// Filter schools by district
function filterSchoolsByDistrict(district) {
    const filteredSchools = currentSchools.filter(school => 
        school.ma_quan_huyen === district
    );
    displaySchoolsOnMap(filteredSchools);
}

// Display schools on map
function displaySchoolsOnMap(schools) {
    // Clear existing markers
    clearMarkers();
    
    // Add new markers
    schools.forEach(school => {
        const marker = L.circleMarker([school.latitude, school.longitude], {
            color: levelColors[school.ma_cap_hoc] || '#333',
            fillColor: levelColors[school.ma_cap_hoc] || '#333',
            fillOpacity: 0.8,
            radius: getMarkerSize(school.so_hoc_sinh),
            weight: 2
        }).addTo(map);
        
        // Create popup content
        const popupContent = createPopupContent(school);
        marker.bindPopup(popupContent);
        
        schoolMarkers.push(marker);
    });
    
    // Fit map to show all markers
    if (schools.length > 0) {
        const group = new L.featureGroup(schoolMarkers);
        map.fitBounds(group.getBounds().pad(0.1));
    }
}

// Clear all markers
function clearMarkers() {
    schoolMarkers.forEach(marker => {
        map.removeLayer(marker);
    });
    schoolMarkers = [];
}

// Get marker size based on student count
function getMarkerSize(studentCount) {
    if (studentCount >= 10000) return 12;
    if (studentCount >= 5000) return 10;
    if (studentCount >= 1000) return 8;
    if (studentCount >= 500) return 6;
    return 4;
}

// Create popup content
function createPopupContent(school) {
    return `
        <div class="school-popup">
            <h5>${school.ten_truong}</h5>
            <div class="info-item">
                <strong>Cấp học:</strong> ${school.ten_cap_hoc}
            </div>
            <div class="info-item">
                <strong>Loại:</strong> ${school.ten_loai_truong}
            </div>
            <div class="info-item">
                <strong>Quận/Huyện:</strong> ${school.ten_quan_huyen}
            </div>
            <div class="info-item">
                <strong>Địa chỉ:</strong> ${school.dia_chi}
            </div>
            <div class="info-item">
                <strong>Số lớp:</strong> ${school.so_lop}
            </div>
            <div class="info-item">
                <strong>Số học sinh:</strong> ${school.so_hoc_sinh.toLocaleString()}
            </div>
            <div class="info-item">
                <strong>Điện thoại:</strong> ${school.dien_thoai || 'N/A'}
            </div>
            <div class="info-item">
                <strong>Email:</strong> ${school.email || 'N/A'}
            </div>
            <div class="info-item">
                <strong>Website:</strong> ${school.website ? `<a href="${school.website}" target="_blank">${school.website}</a>` : 'N/A'}
            </div>
        </div>
    `;
}

// Statistics functions removed - charts not needed on map page

// Chart functions removed - not needed on map page

// Update statistics

// Populate district filter
function populateDistrictFilter() {
    const districts = [...new Set(currentSchools.map(school => school.ten_quan_huyen))];
    const select = document.getElementById('districtFilter');
    
    // Check if select element exists
    if (!select) {
        return;
    }
    
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
    const lngEl = document.getElementById('schoolLongitude');
    const latEl = document.getElementById('schoolLatitude');
    const validationEl = document.getElementById('coordinateValidation');
    
    // Check if elements exist (only on admin page)
    if (!lngEl || !latEl || !validationEl) {
        return;
    }
    
    const lng = lngEl.value;
    const lat = latEl.value;
    
    if (!lng || !lat) {
        validationEl.innerHTML = 
            '<div class="text-warning"><i class="fas fa-exclamation-triangle me-1"></i>Vui lòng nhập tọa độ</div>';
        return;
    }
    
    try {
        const response = await fetch(`api/schools.php?action=validate_coordinates&longitude=${lng}&latitude=${lat}`);
        const data = await response.json();
        
        if (data.success) {
            if (data.is_valid) {
                validationEl.innerHTML = 
                    '<div class="text-success"><i class="fas fa-check-circle me-1"></i>' + data.message + '</div>';
            } else {
                validationEl.innerHTML = 
                    '<div class="text-danger"><i class="fas fa-times-circle me-1"></i>' + data.message + '</div>';
            }
        }
    } catch (error) {
        validationEl.innerHTML = 
            '<div class="text-danger"><i class="fas fa-exclamation-triangle me-1"></i>Lỗi kiểm tra tọa độ</div>';
    }
}

// Add new school
async function addSchool() {
    const form = document.getElementById('addSchoolForm');
    
    // Check if form exists (only on admin page)
    if (!form) {
        return;
    }
    
    const formData = new FormData(form);
    
    // Validate required fields
    const requiredFields = ['schoolName', 'schoolLevel', 'schoolType', 'schoolDistrict', 'schoolAddress', 'schoolLongitude', 'schoolLatitude'];
    for (let field of requiredFields) {
        const fieldEl = document.getElementById(field);
        if (!fieldEl || !fieldEl.value) {
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
            const modal = document.getElementById('addSchoolModal');
            if (modal) {
                modal.querySelector('.btn-close').click();
            }
            form.reset();
            loadAllSchools();
        } else {
            showError('Lỗi thêm trường học: ' + data.error);
        }
    } catch (error) {
        showError('Lỗi kết nối: ' + error.message);
    }
}

// Utility functions
function showLoading() {
    // You can add a loading indicator here
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
