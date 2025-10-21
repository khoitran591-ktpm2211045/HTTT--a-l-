// Global variables for map page
let map;
let schoolMarkers = [];
let currentSchools = [];
let currentEditingSchool = null;
let mapPickerMarker = null;
let searchResults = []; // Store search results for click navigation

// School level colors
const levelColors = {
    'DH': '#e74c3c',    // Đại học - Đỏ
    'CD': '#f39c12',    // Cao đẳng - Cam
    'THPT': '#27ae60',  // THPT - Xanh lá
    'THCS': '#3498db',  // THCS - Xanh dương
    'TH': '#9b59b6',    // Tiểu học - Tím
    'MN': '#e67e22'     // Mầm non - Cam đậm
};

// Initialize the map application
document.addEventListener('DOMContentLoaded', function() {
    initializeMap();
    loadAllSchools();
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
}

// Load all schools
async function loadAllSchools() {
    try {
        const response = await fetch('api/schools.php?action=get_all');
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
        const popupContent = createMapPopupContent(school);
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
function createMapPopupContent(school) {
    console.log('Creating popup for school:', school.ten_truong, 'with coordinates:', school.latitude, school.longitude);
    console.log('Using map.js createMapPopupContent function - fields removed version');
    return `
        <div class="school-popup">
            <h5>${school.ten_truong}</h5>
            <div class="info-item">
                <strong>Cấp học:</strong> ${school.ten_cap_hoc}
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
                <strong>Vĩ độ:</strong> ${Number(school.latitude).toFixed(15)}
            </div>
            <div class="info-item">
                <strong>Kinh độ:</strong> ${Number(school.longitude).toFixed(15)}
            </div>
            <div class="popup-actions">
                <button class="btn btn-primary edit-school-btn" onclick="editSchool('${school.id}')" title="Chỉnh sửa">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="btn btn-success edit-position-btn" onclick="editPosition('${school.id}')" title="Chỉnh sửa vị trí">
                    <i class="fas fa-map-marker-alt"></i>
                </button>
            </div>
        </div>
    `;
}

// Edit school functions
function editSchool(schoolId) {
    const school = currentSchools.find(s => s.id == schoolId);
    if (!school) {
        showError('Không tìm thấy thông tin trường học');
        return;
    }
    
    currentEditingSchool = school;
    
    // Fill form with school data
    document.getElementById('editSchoolId').value = school.id;
    document.getElementById('editSchoolName').value = school.ten_truong;
    document.getElementById('editSchoolLevel').value = school.ma_cap_hoc;
    document.getElementById('editSchoolDistrict').value = school.ma_quan_huyen;
    document.getElementById('editSchoolAddress').value = school.dia_chi;
    document.getElementById('editSchoolClasses').value = school.so_lop;
    document.getElementById('editSchoolStudents').value = school.so_hoc_sinh;
    document.getElementById('editSchoolWebsite').value = school.website || '';
    document.getElementById('editSchoolLatitude').value = school.latitude;
    document.getElementById('editSchoolLongitude').value = school.longitude;
    
    // Show modal
    const modal = new bootstrap.Modal(document.getElementById('editSchoolModal'));
    modal.show();
}

// Edit position directly on map
function editPosition(schoolId) {
    console.log('editPosition called with schoolId:', schoolId);
    const school = currentSchools.find(s => s.id == schoolId);
    if (!school) {
        showError('Không tìm thấy thông tin trường học');
        return;
    }
    console.log('Found school:', school);
    
    currentEditingSchool = school;
    
    // Remove existing picker marker
    if (mapPickerMarker) {
        map.removeLayer(mapPickerMarker);
    }
    
    // Center map on school location
    map.setView([school.latitude, school.longitude], 16);
    
    // Add current position marker
    mapPickerMarker = L.marker([school.latitude, school.longitude], {
        icon: L.divIcon({
            className: 'map-picker-marker',
            html: '<i class="fas fa-map-marker-alt" style="color: #e74c3c; font-size: 24px;"></i>',
            iconSize: [24, 24],
            iconAnchor: [12, 24]
        })
    }).addTo(map);
    
    // Add click event to map
    map.on('click', onMapClickForPosition);
    
    // Show instruction
    alert('Nhấp vào vị trí mới trên bản đồ để di chuyển trường học. Nhấp vào marker đỏ để xác nhận vị trí hiện tại.');
}

// Handle map click for position editing
function onMapClickForPosition(e) {
    const lat = e.latlng.lat;
    const lng = e.latlng.lng;
    
    // Remove existing picker marker
    if (mapPickerMarker) {
        map.removeLayer(mapPickerMarker);
    }
    
    // Add new picker marker
    mapPickerMarker = L.marker([lat, lng], {
        icon: L.divIcon({
            className: 'map-picker-marker',
            html: '<i class="fas fa-map-marker-alt" style="color: #e74c3c; font-size: 24px;"></i>',
            iconSize: [24, 24],
            iconAnchor: [12, 24]
        })
    }).addTo(map);
    
    // Add click event to marker for confirmation
    mapPickerMarker.on('click', function() {
        confirmPositionUpdate(lat, lng);
    });
    
    // Remove map click event
    map.off('click', onMapClickForPosition);
}

// Confirm position update
function confirmPositionUpdate(lat, lng) {
    if (confirm(`Bạn có chắc muốn cập nhật vị trí trường "${currentEditingSchool.ten_truong}"?\n\nVị trí mới:\nVĩ độ: ${lat.toFixed(15)}\nKinh độ: ${lng.toFixed(15)}`)) {
        updateSchoolPosition(lat, lng);
    } else {
        // Restore original position
        if (mapPickerMarker) {
            map.removeLayer(mapPickerMarker);
        }
        mapPickerMarker = L.marker([currentEditingSchool.latitude, currentEditingSchool.longitude], {
            icon: L.divIcon({
                className: 'map-picker-marker',
                html: '<i class="fas fa-map-marker-alt" style="color: #e74c3c; font-size: 24px;"></i>',
                iconSize: [24, 24],
                iconAnchor: [12, 24]
            })
        }).addTo(map);
        
        // Re-add click event
        map.on('click', onMapClickForPosition);
    }
}

// Update school position
async function updateSchoolPosition(lat, lng) {
    if (!currentEditingSchool) return;
    
    const formData = new FormData();
    formData.append('action', 'update_position');
    formData.append('id', currentEditingSchool.id);
    formData.append('latitude', lat);
    formData.append('longitude', lng);
    
    try {
        const response = await fetch('api/schools.php', {
            method: 'POST',
            body: formData
        });
        
        const data = await response.json();
        
        if (data.success) {
            // Update local data
            const schoolIndex = currentSchools.findIndex(s => s.id == currentEditingSchool.id);
            if (schoolIndex !== -1) {
                currentSchools[schoolIndex].latitude = lat;
                currentSchools[schoolIndex].longitude = lng;
            }
            
            // Refresh map
            displaySchoolsOnMap(currentSchools);
            
            // Clear picker marker
            if (mapPickerMarker) {
                map.removeLayer(mapPickerMarker);
                mapPickerMarker = null;
            }
            
            // Show success message
            alert('Cập nhật vị trí trường học thành công!');
            
            currentEditingSchool = null;
        } else {
            showError('Lỗi cập nhật: ' + data.error);
        }
    } catch (error) {
        showError('Lỗi kết nối: ' + error.message);
    }
}

// Open map picker for location selection
function openMapPicker() {
    if (!currentEditingSchool) return;
    
    // Remove existing picker marker
    if (mapPickerMarker) {
        map.removeLayer(mapPickerMarker);
    }
    
    // Add click event to map
    map.on('click', onMapClick);
    
    // Show instruction
    alert('Nhấp vào vị trí mong muốn trên bản đồ để chọn vị trí mới cho trường học');
}

// Handle map click for location picking
function onMapClick(e) {
    const lat = e.latlng.lat;
    const lng = e.latlng.lng;
    
    // Update form fields
    document.getElementById('editSchoolLatitude').value = lat.toFixed(15);
    document.getElementById('editSchoolLongitude').value = lng.toFixed(15);
    
    // Remove existing picker marker
    if (mapPickerMarker) {
        map.removeLayer(mapPickerMarker);
    }
    
    // Add new picker marker
    mapPickerMarker = L.marker([lat, lng], {
        icon: L.divIcon({
            className: 'map-picker-marker',
            html: '<i class="fas fa-map-marker-alt" style="color: #e74c3c; font-size: 24px;"></i>',
            iconSize: [24, 24],
            iconAnchor: [12, 24]
        })
    }).addTo(map);
    
    // Remove click event
    map.off('click', onMapClick);
}

// Save school changes
async function saveSchoolChanges() {
    if (!currentEditingSchool) return;
    
    const form = document.getElementById('editSchoolForm');
    const formData = new FormData(form);
    
    // Add action
    formData.append('action', 'update');
    
    try {
        const response = await fetch('api/schools.php', {
            method: 'POST',
            body: formData
        });
        
        const data = await response.json();
        
        if (data.success) {
            // Update local data
            const schoolIndex = currentSchools.findIndex(s => s.id == currentEditingSchool.id);
            if (schoolIndex !== -1) {
                currentSchools[schoolIndex] = { ...currentSchools[schoolIndex], ...data.data };
            }
            
            // Refresh map
            displaySchoolsOnMap(currentSchools);
            
            // Close modal
            const modal = bootstrap.Modal.getInstance(document.getElementById('editSchoolModal'));
            modal.hide();
            
            // Show success message
            alert('Cập nhật thông tin trường học thành công!');
            
            // Clear picker marker
            if (mapPickerMarker) {
                map.removeLayer(mapPickerMarker);
                mapPickerMarker = null;
            }
            
            currentEditingSchool = null;
        } else {
            showError('Lỗi cập nhật: ' + data.error);
        }
    } catch (error) {
        showError('Lỗi kết nối: ' + error.message);
    }
}

// Navigate to school marker on map
function navigateToSchool(schoolId) {
    // Find the school in search results
    const school = searchResults.find(s => s.id == schoolId);
    if (!school) {
        showError('Không tìm thấy thông tin trường học');
        return;
    }
    
    // Find the corresponding marker
    const marker = schoolMarkers.find(m => {
        const lat = m.getLatLng().lat;
        const lng = m.getLatLng().lng;
        return Math.abs(lat - school.latitude) < 0.0001 && Math.abs(lng - school.longitude) < 0.0001;
    });
    
    if (marker) {
        // Center map on the marker
        map.setView([school.latitude, school.longitude], 16);
        
        // Open popup for the marker
        marker.openPopup();
        
        // Add a temporary highlight effect
        marker.setStyle({
            color: '#ff0000',
            weight: 4,
            fillOpacity: 1
        });
        
        // Reset style after 2 seconds
        setTimeout(() => {
            marker.setStyle({
                color: levelColors[school.ma_cap_hoc] || '#333',
                weight: 2,
                fillOpacity: 0.8
            });
        }, 2000);
    } else {
        showError('Không tìm thấy marker của trường trên bản đồ');
    }
}

// Utility functions
function showError(message) {
    // Create or update error message
    let errorDiv = document.getElementById('errorMessage');
    if (!errorDiv) {
        errorDiv = document.createElement('div');
        errorDiv.id = 'errorMessage';
        errorDiv.className = 'error-message';
        document.querySelector('.search-panel').appendChild(errorDiv);
    }
    
    errorDiv.innerHTML = `
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-triangle me-2"></i>
            ${message}
        </div>
    `;
    
    // Auto hide after 5 seconds
    setTimeout(() => {
        if (errorDiv) {
            errorDiv.remove();
        }
    }, 5000);
}

// Search functionality
function searchSchools() {
    try {
        // Clear any previous error messages
        hideError();
        
        // Show loading indicator
        showLoading();
        
        const minStudents = document.getElementById('searchMinStudents').value;
        
        // Validation
        if (!minStudents) {
            showError('Vui lòng nhập số học sinh tối thiểu!');
            return;
        }
        
        if (isNaN(minStudents) || parseInt(minStudents) < 0) {
            showError('Số học sinh phải là số dương');
            return;
        }
        
        // Check if we have schools data
        if (!currentSchools || currentSchools.length === 0) {
            showError('Chưa có dữ liệu trường học. Vui lòng thử lại sau.');
            return;
        }
        
        // Filter schools based on search criteria
        let filteredSchools = currentSchools.filter(school => {
            try {
                // Min students filter
                const schoolStudents = parseInt(school.so_hoc_sinh) || 0;
                const minStudentsNum = parseInt(minStudents);
                if (schoolStudents < minStudentsNum) {
                    return false;
                }
                
                return true;
            } catch (error) {
                console.error('Error filtering school:', school, error);
                return false;
            }
        });
        
        // Store search results for navigation
        searchResults = filteredSchools;
        
        // Clear current markers
        clearMarkers();
        
        // Display filtered schools
        displaySchoolsOnMap(filteredSchools);
        
        // Show search results count and table
        if (filteredSchools.length === 0) {
            showError('Không tìm thấy trường nào có số học sinh >= ' + minStudents);
            hideSearchResults();
            hideResultsTable();
        } else {
            showSearchResults(filteredSchools.length, minStudents);
            showResultsTable(filteredSchools);
        }
        
        // Log search activity
        console.log(`Search completed: ${filteredSchools.length} schools found`);
        
        // Hide loading indicator
        hideLoading();
        
    } catch (error) {
        console.error('Search error:', error);
        showError('Lỗi khi tìm kiếm: ' + error.message);
        hideLoading();
    }
}

function clearSearch() {
    // Reset form field
    document.getElementById('searchMinStudents').value = '';
    
    // Clear search results
    searchResults = [];
    
    // Clear current markers
    clearMarkers();
    
    // Display all schools
    displaySchoolsOnMap(currentSchools);
    
    // Hide search results, errors, table and loading
    hideSearchResults();
    hideError();
    hideResultsTable();
    hideLoading();
}

function showSearchResults(count, minStudents) {
    // Create or update search results indicator
    let resultsDiv = document.getElementById('searchResults');
    if (!resultsDiv) {
        resultsDiv = document.createElement('div');
        resultsDiv.id = 'searchResults';
        resultsDiv.className = 'search-results';
        document.querySelector('.search-panel').appendChild(resultsDiv);
    }
    
    resultsDiv.innerHTML = ``;
}

function hideSearchResults() {
    const resultsDiv = document.getElementById('searchResults');
    if (resultsDiv) {
        resultsDiv.remove();
    }
}

function showResultsTable(schools) {
    const tableDiv = document.getElementById('resultsTable');
    const tableBody = document.getElementById('resultsTableBody');
    
    if (tableDiv && tableBody) {
        // Clear existing rows
        tableBody.innerHTML = '';
        
        // Add schools to table
        schools.forEach(school => {
            const row = document.createElement('tr');
            const studentCount = school.so_hoc_sinh || 0;
            row.innerHTML = `
                <td><strong>${school.ten_truong}</strong></td>
                <td><span class="badge bg-primary">${studentCount.toLocaleString()}</span></td>
                <td>${school.dia_chi}</td>
            `;
            
            // Add click handler to navigate to school marker
            row.style.cursor = 'pointer';
            row.addEventListener('click', function() {
                navigateToSchool(school.id);
            });
            
            // Add hover effect
            row.addEventListener('mouseenter', function() {
                this.style.backgroundColor = '#e3f2fd';
            });
            
            row.addEventListener('mouseleave', function() {
                this.style.backgroundColor = '';
            });
            
            tableBody.appendChild(row);
        });
        
        // Show table
        tableDiv.style.display = 'block';
    }
}

function hideResultsTable() {
    const tableDiv = document.getElementById('resultsTable');
    if (tableDiv) {
        tableDiv.style.display = 'none';
    }
}

function hideError() {
    const errorDiv = document.getElementById('errorMessage');
    if (errorDiv) {
        errorDiv.remove();
    }
    // Also hide results table when hiding error
    hideResultsTable();
}

function showLoading() {
    let loadingDiv = document.getElementById('loadingIndicator');
    if (!loadingDiv) {
        loadingDiv = document.createElement('div');
        loadingDiv.id = 'loadingIndicator';
        loadingDiv.className = 'loading-indicator';
        document.querySelector('.search-panel').appendChild(loadingDiv);
    }
    
    loadingDiv.innerHTML = `
        <div class="alert alert-info">
            <i class="fas fa-spinner fa-spin me-2"></i>
            Đang tìm kiếm...
        </div>
    `;
}

function hideLoading() {
    const loadingDiv = document.getElementById('loadingIndicator');
    if (loadingDiv) {
        loadingDiv.remove();
    }
}

function handleEnterKey(event) {
    if (event.key === 'Enter') {
        searchSchools();
    }
}

// Export functions for global access
window.loadAllSchools = loadAllSchools;
window.editSchool = editSchool;
window.editPosition = editPosition;
window.openMapPicker = openMapPicker;
window.saveSchoolChanges = saveSchoolChanges;
window.searchSchools = searchSchools;
window.clearSearch = clearSearch;
window.handleEnterKey = handleEnterKey;
window.navigateToSchool = navigateToSchool;