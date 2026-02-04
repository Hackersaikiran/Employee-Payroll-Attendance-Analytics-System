// API Base URL
const API_BASE_URL = 'http://localhost:3000/api';

document.addEventListener('DOMContentLoaded', () => {
    initializeApp();
    setupFormHandlers();
    const navButtons = document.querySelectorAll('.nav-btn');
    navButtons.forEach(btn => {
        btn.addEventListener('click', (e) => switchPage(e.target.dataset.page));
    });
});

function initializeApp() {
    loadEmployees();
    loadDepartments();
    loadAttendance();
    loadPayroll();
    const today = new Date().toISOString().split('T')[0];
    if (document.getElementById('attendance_date')) {
        document.getElementById('attendance_date').value = today;
    }
    if (document.getElementById('date_of_joining')) {
        document.getElementById('date_of_joining').value = today;
    }
}

function switchPage(pageName) {
    document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));
    document.getElementById(`${pageName}-page`).classList.add('active');
    event.target.classList.add('active');
    
    // Reload data for the specific page
    if (pageName === 'payroll') {
        loadPayroll();
    } else if (pageName === 'attendance') {
        loadAttendance();
    } else if (pageName === 'employees') {
        loadEmployees();
    } else if (pageName === 'departments') {
        loadDepartments();
    }
}

function setupFormHandlers() {
    const empForm = document.getElementById('employee-form');
    const attForm = document.getElementById('attendance-form');
    const payrollForm = document.getElementById('payroll-generation-form');
    
    if (empForm) empForm.addEventListener('submit', handleEmployeeSubmit);
    if (attForm) attForm.addEventListener('submit', handleAttendanceSubmit);
    if (payrollForm) payrollForm.addEventListener('submit', handlePayrollGeneration);
}

// ============ EMPLOYEES ============
async function loadEmployees() {
    try {
        const response = await fetch(`${API_BASE_URL}/employees`);
        if (!response.ok) {
            console.error('Failed to load employees: HTTP', response.status);
            displayEmployees([]);
            return;
        }
        const result = await response.json();
        const employees = result.data || [];
        displayEmployees(employees);
        
        // Populate employee dropdown for attendance form
        const empSelect = document.getElementById('attendance_employee_id');
        if (empSelect) {
            empSelect.innerHTML = '<option value="">Select Employee</option>' + 
                employees.map(e => `<option value="${e.employee_id}">${e.first_name} ${e.last_name}</option>`).join('');
        }
    } catch (error) {
        console.error('Failed to load employees:', error);
        displayEmployees([]);
    }
}

function displayEmployees(employees) {
    const tbody = document.getElementById('employees-table-body');
    if (!tbody) return;
    
    if (employees.length === 0) {
        tbody.innerHTML = '<tr><td colspan="9" class="loading">No employees found</td></tr>';
        return;
    }
    
    tbody.innerHTML = employees.map(emp => `
        <tr>
            <td>${emp.employee_id}</td>
            <td>${emp.first_name} ${emp.last_name}</td>
            <td>${emp.email}</td>
            <td>${emp.phone}</td>
            <td>${emp.designation}</td>
            <td>${emp.department_name}</td>
            <td>₹${parseFloat(emp.base_salary).toFixed(2)}</td>
            <td>${emp.date_of_joining}</td>
            <td>${emp.is_active ? 'Yes' : 'No'}</td>
        </tr>
    `).join('');
}

function showAddEmployeeForm() {
    document.getElementById('add-employee-form').classList.remove('hidden');
}

function hideAddEmployeeForm() {
    document.getElementById('add-employee-form').classList.add('hidden');
}

async function handleEmployeeSubmit(e) {
    e.preventDefault();
    const formData = new FormData(this);
    const data = Object.fromEntries(formData);
    
    try {
        const response = await fetch(`${API_BASE_URL}/employees`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        
        if (response.ok) {
            alert('Employee added successfully');
            this.reset();
            document.getElementById('add-employee-form').classList.add('hidden');
            loadEmployees();
        } else {
            const error = await response.json();
            alert('Failed to add employee: ' + (error.error || 'Unknown error'));
        }
    } catch (error) {
        alert('Error: ' + error.message);
    }
}

// ============ DEPARTMENTS ============
async function loadDepartments() {
    try {
        const response = await fetch(`${API_BASE_URL}/departments`);
        if (!response.ok) {
            console.error('Failed to load departments: HTTP', response.status);
            displayDepartments([]);
            return;
        }
        const result = await response.json();
        const depts = result.data || [];
        
        // Populate department dropdowns
        const selects = document.querySelectorAll('select[name="department_id"]');
        selects.forEach(select => {
            select.innerHTML = '<option value="">Select Department</option>' + 
                depts.map(d => `<option value="${d.department_id}">${d.department_name}</option>`).join('');
        });
        
        // Display departments table
        displayDepartments(depts);
    } catch (error) {
        console.error('Failed to load departments:', error);
        displayDepartments([]);
    }
}

function displayDepartments(departments) {
    const tbody = document.getElementById('departments-table-body');
    if (!tbody) return;
    
    if (departments.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" class="loading">No departments found</td></tr>';
        return;
    }
    
    tbody.innerHTML = departments.map(d => `
        <tr>
            <td>${d.department_id}</td>
            <td>${d.department_name}</td>
            <td>${d.location || '-'}</td>
            <td>${new Date(d.created_at).toLocaleDateString()}</td>
        </tr>
    `).join('');
}

// ============ ATTENDANCE ============
async function loadAttendance() {
    try {
        const response = await fetch(`${API_BASE_URL}/attendance`);
        if (!response.ok) {
            console.error('Failed to load attendance: HTTP', response.status);
            displayAttendance([]);
            return;
        }
        const result = await response.json();
        displayAttendance(result.data || []);
    } catch (error) {
        console.error('Failed to load attendance:', error);
        displayAttendance([]);
    }
}

function displayAttendance(attendance) {
    const tbody = document.getElementById('attendance-table-body');
    if (!tbody) return;
    
    if (attendance.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="loading">No attendance records found</td></tr>';
        return;
    }
    
    tbody.innerHTML = attendance.map(a => `
        <tr>
            <td>${a.attendance_id}</td>
            <td>${a.first_name} ${a.last_name}</td>
            <td>${a.department_name}</td>
            <td>${a.attendance_date}</td>
            <td>${a.status}</td>
            <td>${a.check_in_time || '-'}</td>
            <td>${a.check_out_time || '-'}</td>
            <td>${a.remarks || '-'}</td>
        </tr>
    `).join('');
}

function showMarkAttendanceForm() {
    document.getElementById('mark-attendance-form').classList.remove('hidden');
}

function hideMarkAttendanceForm() {
    document.getElementById('mark-attendance-form').classList.add('hidden');
}

function toggleTimeFields() {
    const status = document.getElementById('status').value;
    const checkInField = document.getElementById('check_in_time');
    const checkOutField = document.getElementById('check_out_time');
    
    if (status === 'Absent') {
        checkInField.disabled = true;
        checkOutField.disabled = true;
    } else {
        checkInField.disabled = false;
        checkOutField.disabled = false;
    }
}

function filterAttendance() {
    const month = document.getElementById('filter_month').value;
    const year = document.getElementById('filter_year').value;
    
    let url = `${API_BASE_URL}/attendance`;
    const params = new URLSearchParams();
    if (month) params.append('month', month);
    if (year) params.append('year', year);
    if (params.toString()) url += '?' + params.toString();
    
    fetch(url)
        .then(res => res.json())
        .then(result => displayAttendance(result.data || []))
        .catch(error => console.error('Failed to filter attendance:', error));
}

async function handleAttendanceSubmit(e) {
    e.preventDefault();
    const formData = new FormData(this);
    const data = Object.fromEntries(formData);
    
    try {
        const response = await fetch(`${API_BASE_URL}/attendance`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        
        if (response.ok) {
            alert('Attendance marked successfully');
            this.reset();
            document.getElementById('mark-attendance-form').classList.add('hidden');
            loadAttendance();
        } else {
            const error = await response.json();
            alert('Failed to mark attendance: ' + (error.error || 'Unknown error'));
        }
    } catch (error) {
        alert('Error: ' + error.message);
    }
}

// ============ PAYROLL ============
async function loadPayroll() {
    try {
        // Get current month and year
        const today = new Date();
        const currentMonth = today.getMonth() + 1; // JavaScript months are 0-indexed
        const currentYear = today.getFullYear();
        
        // Fetch payroll data for current month by default
        const response = await fetch(`${API_BASE_URL}/payroll?month=${currentMonth}&year=${currentYear}`);
        if (!response.ok) {
            console.error('Failed to load payroll: HTTP', response.status);
            displayPayroll([]);
            return;
        }
        const result = await response.json();
        displayPayroll(result.data || []);
        
        // Set filter dropdowns to current month/year
        const filterMonth = document.getElementById('payroll_filter_month');
        const filterYear = document.getElementById('payroll_filter_year');
        if (filterMonth) filterMonth.value = currentMonth.toString();
        if (filterYear) filterYear.value = currentYear.toString();
    } catch (error) {
        console.error('Failed to load payroll:', error);
        displayPayroll([]);
    }
}

function displayPayroll(payroll) {
    const tbody = document.getElementById('payroll-table-body');
    if (!tbody) return;
    
    if (payroll.length === 0) {
        tbody.innerHTML = '<tr><td colspan="10" class="loading">No payroll records found</td></tr>';
        return;
    }
    
    tbody.innerHTML = payroll.map(p => {
        const presentDays = p.present_days || 0;
        const totalDays = p.total_days || 1; // Avoid division by zero
        const attendancePercent = totalDays > 0 ? ((presentDays / totalDays) * 100).toFixed(2) : 0;
        
        return `
        <tr>
            <td>${p.first_name} ${p.last_name}</td>
            <td>${p.department_name || '-'}</td>
            <td>${p.month}/${p.year}</td>
            <td>₹${parseFloat(p.base_salary).toFixed(2)}</td>
            <td>${p.present_days || 0}</td>
            <td>${p.late_days || 0}</td>
            <td>${p.absent_days || 0}</td>
            <td>₹${parseFloat(p.total_deduction).toFixed(2)}</td>
            <td>₹${parseFloat(p.net_salary).toFixed(2)}</td>
            <td>${attendancePercent}%</td>
        </tr>
    `}).join('');
}

function showGeneratePayrollForm() {
    document.getElementById('generate-payroll-form').classList.remove('hidden');
}

function hideGeneratePayrollForm() {
    document.getElementById('generate-payroll-form').classList.add('hidden');
}

function filterPayroll() {
    const month = document.getElementById('payroll_filter_month').value;
    const year = document.getElementById('payroll_filter_year').value;
    
    let url = `${API_BASE_URL}/payroll`;
    const params = new URLSearchParams();
    
    if (month && month !== '') {
        params.append('month', parseInt(month));
    }
    if (year && year !== '') {
        params.append('year', parseInt(year));
    }
    
    if (params.toString()) {
        url += '?' + params.toString();
    }
    
    fetch(url)
        .then(res => res.json())
        .then(result => {
            displayPayroll(result.data || []);
        })
        .catch(error => console.error('Failed to filter payroll:', error));
}

async function handlePayrollGeneration(e) {
    e.preventDefault();
    const formData = new FormData(this);
    const month = formData.get('month');
    const year = formData.get('year');
    
    if (!month || !year) {
        alert('Please select both month and year');
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/payroll/generate`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                month: parseInt(month), 
                year: parseInt(year) 
            })
        });
        
        if (response.ok) {
            alert('Payroll generated successfully');
            document.getElementById('generate-payroll-form').classList.add('hidden');
            // Set filters to show the generated month
            const filterMonth = document.getElementById('payroll_filter_month');
            const filterYear = document.getElementById('payroll_filter_year');
            if (filterMonth) filterMonth.value = month;
            if (filterYear) filterYear.value = year;
            // Fetch and display the generated payroll data
            loadPayrollForMonth(parseInt(month), parseInt(year));
        } else {
            const error = await response.json();
            alert('Failed to generate payroll: ' + (error.error || 'Unknown error'));
        }
    } catch (error) {
        alert('Error: ' + error.message);
    }
}

// Helper function to load payroll for a specific month
async function loadPayrollForMonth(month, year) {
    try {
        const response = await fetch(`${API_BASE_URL}/payroll?month=${month}&year=${year}`);
        if (!response.ok) {
            console.error('Failed to load payroll: HTTP', response.status);
            displayPayroll([]);
            return;
        }
        const result = await response.json();
        displayPayroll(result.data || []);
    } catch (error) {
        console.error('Failed to load payroll:', error);
        displayPayroll([]);
    }
}

// ============ SEARCH FUNCTIONS ============

// Store original data for search filtering
let allEmployees = [];
let allAttendance = [];
let allPayroll = [];

// Override displayEmployees to cache data
const originalDisplayEmployees = displayEmployees;
displayEmployees = function(employees) {
    allEmployees = employees;
    originalDisplayEmployees(employees);
};

// Override displayAttendance to cache data
const originalDisplayAttendance = displayAttendance;
displayAttendance = function(attendance) {
    allAttendance = attendance;
    originalDisplayAttendance(attendance);
};

// Override displayPayroll to cache data
const originalDisplayPayroll = displayPayroll;
displayPayroll = function(payroll) {
    allPayroll = payroll;
    originalDisplayPayroll(payroll);
};

// Search Employees by ID, Name, or Designation
function searchEmployees() {
    const searchTerm = document.getElementById('employee_search').value.toLowerCase();
    
    if (!searchTerm) {
        originalDisplayEmployees(allEmployees);
        return;
    }
    
    const filtered = allEmployees.filter(emp => {
        const id = emp.employee_id.toString();
        const name = `${emp.first_name} ${emp.last_name}`.toLowerCase();
        const designation = (emp.designation || '').toLowerCase();
        
        return id.includes(searchTerm) || name.includes(searchTerm) || designation.includes(searchTerm);
    });
    
    originalDisplayEmployees(filtered);
}

// Search Attendance by Employee ID, Name, or Designation
function searchAttendance() {
    const searchTerm = document.getElementById('attendance_search').value.toLowerCase();
    
    if (!searchTerm) {
        originalDisplayAttendance(allAttendance);
        return;
    }
    
    const filtered = allAttendance.filter(att => {
        const empId = att.employee_id.toString();
        const name = `${att.first_name} ${att.last_name}`.toLowerCase();
        const designation = (att.designation || '').toLowerCase();
        
        return empId.includes(searchTerm) || name.includes(searchTerm) || designation.includes(searchTerm);
    });
    
    originalDisplayAttendance(filtered);
}

// Search Payroll by Employee ID, Name, or Designation
function searchPayroll() {
    const searchTerm = document.getElementById('payroll_search').value.toLowerCase();
    
    if (!searchTerm) {
        originalDisplayPayroll(allPayroll);
        return;
    }
    
    const filtered = allPayroll.filter(payroll => {
        const empId = payroll.employee_id.toString();
        const name = `${payroll.first_name} ${payroll.last_name}`.toLowerCase();
        const designation = (payroll.designation || '').toLowerCase();
        
        return empId.includes(searchTerm) || name.includes(searchTerm) || designation.includes(searchTerm);
    });
    
    originalDisplayPayroll(filtered);
}
