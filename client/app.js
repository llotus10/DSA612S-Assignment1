const apiBase = 'http://localhost:9091/api/library';

const assetGrid = document.querySelector('#assetGrid');
const message = document.querySelector('#message');
const institutionDatalist = document.querySelector('#institutionDatalist');
const institutionList = document.querySelector('#institutionList');

// Helper to show temporary feedback messages
function showMessage(text, isError = false) {
    message.textContent = text;
    message.style.color = isError ? '#b91c1c' : '#126b69';
}

// Convert status text to a CSS class name
function getStatusClass(status) {
    if (!status) return 'available';
    const s = status.toLowerCase();
    if (s.includes('available')) return 'available';
    if (s.includes('loan')) return 'loaned_out';
    if (s.includes('maint')) return 'under_maintenance';
    return 'disposed';
}

// Render asset cards into the grid
function renderAssets(assets) {
    assetGrid.innerHTML = '';
    if (!assets || !assets.length) {
        assetGrid.innerHTML = '<p class="sub-text">No assets found for this view.</p>';
        return;
    }

    assets.forEach((asset) => {
        const card = document.createElement('article');
        card.className = 'asset-card';
        const statusClass = getStatusClass(asset.status);

        card.innerHTML = `
            <div>
                <div class="tag">${asset.assetTag}</div>
                <h2>${asset.name}</h2>
                <p>${asset.description || 'No description provided.'}</p>
                <p><strong>Institution:</strong> ${asset.institution}</p>
                <p><strong>Site:</strong> ${asset.site}</p>
                <span class="status ${statusClass}">${asset.status}</span>
            </div>
            <div class="card-actions">
                ${asset.status === 'AVAILABLE' ? `<button class="button loan-button" data-action="loan" data-tag="${asset.assetTag}">Loan asset</button>` : ''}
                ${asset.status === 'LOANED_OUT' ? `<button class="button return-button" data-action="return" data-tag="${asset.assetTag}">Return asset</button>` : ''}
                <button class="button danger-small" data-action="delete" data-tag="${asset.assetTag}">Delete</button>
            </div>
        `;
        assetGrid.appendChild(card);
    });
}

// Load and display assets from the API
async function loadAssets(path = '/assets') {
    showMessage('Loading assets...');
    try {
        const response = await fetch(apiBase + path);
        if (!response.ok) throw new Error(`Status ${response.status}`);
        const assets = await response.json();
        renderAssets(assets);
        showMessage(`${assets.length} asset${assets.length === 1 ? '' : 's'} displayed.`);
    } catch (error) {
        showMessage(`Could not load assets: ${error.message}`, true);
    }
}

// Load registered institutions and update UI dropdowns & badges
async function loadInstitutions() {
    try {
        const response = await fetch(apiBase + '/institutions');
        if (!response.ok) return;
        const institutions = await response.json();

        // Update datalist for auto-complete
        institutionDatalist.innerHTML = '';
        institutions.forEach((inst) => {
            const option = document.createElement('option');
            option.value = inst;
            institutionDatalist.appendChild(option);
        });

        // Update institution badge pills
        institutionList.innerHTML = '';
        institutions.forEach((inst) => {
            const badge = document.createElement('span');
            badge.className = 'inst-badge';
            badge.textContent = inst;
            institutionList.appendChild(badge);
        });
    } catch (error) {
        console.error('Failed to load institutions:', error);
    }
}

// Handle Loan, Return, and Delete actions directly on asset cards
assetGrid.addEventListener('click', async (event) => {
    const button = event.target.closest('button[data-action]');
    if (!button) return;

    const action = button.dataset.action;
    const tag = button.dataset.tag;
    button.disabled = true;

    try {
        if (action === 'loan') {
            const res = await fetch(`${apiBase}/assets/${encodeURIComponent(tag)}/loan`, { method: 'PATCH' });
            if (!res.ok) throw new Error(`Failed to loan (${res.status})`);
            showMessage(`Asset "${tag}" successfully loaned.`);
        } else if (action === 'return') {
            const res = await fetch(`${apiBase}/assets/${encodeURIComponent(tag)}/release`, { method: 'PATCH' });
            if (!res.ok) throw new Error(`Failed to return (${res.status})`);
            showMessage(`Asset "${tag}" successfully returned.`);
        } else if (action === 'delete') {
            if (!confirm(`Are you sure you want to delete asset "${tag}"?`)) {
                button.disabled = false;
                return;
            }
            const res = await fetch(`${apiBase}/assets/${encodeURIComponent(tag)}`, { method: 'DELETE' });
            if (!res.ok) throw new Error(`Failed to delete (${res.status})`);
            showMessage(`Asset "${tag}" deleted.`);
        }
        loadAssets();
    } catch (error) {
        showMessage(error.message, true);
        button.disabled = false;
    }
});

// Refresh button
document.querySelector('#refreshButton').addEventListener('click', () => {
    document.querySelector('#institutionInput').value = '';
    document.querySelector('#siteInput').value = '';
    loadAssets();
});

// Overdue maintenance button
document.querySelector('#overdueButton').addEventListener('click', () => {
    loadAssets('/assets/maintenance/overdue');
});

// Filter by institution and site
document.querySelector('#filterButton').addEventListener('click', () => {
    const institution = document.querySelector('#institutionInput').value.trim();
    const site = document.querySelector('#siteInput').value.trim();
    if (!institution) {
        return loadAssets();
    }
    let path = `/assets/institution/${encodeURIComponent(institution)}`;
    if (site) {
        path += `/site/${encodeURIComponent(site)}`;
    }
    loadAssets(path);
});

// Clear filter button
document.querySelector('#clearFilterButton').addEventListener('click', () => {
    document.querySelector('#institutionInput').value = '';
    document.querySelector('#siteInput').value = '';
    loadAssets();
});

// Add New Asset Form
document.querySelector('#addAssetForm').addEventListener('submit', async (event) => {
    event.preventDefault();
    const payload = {
        assetTag: document.querySelector('#newAssetTag').value.trim(),
        name: document.querySelector('#newAssetName').value.trim(),
        description: document.querySelector('#newAssetDesc').value.trim(),
        institution: document.querySelector('#newAssetInst').value.trim(),
        site: document.querySelector('#newAssetSite').value.trim(),
        dateAcquired: document.querySelector('#newAssetDate').value,
        status: document.querySelector('#newAssetStatus').value
    };

    try {
        const response = await fetch(`${apiBase}/assets`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        if (!response.ok) {
            const err = await response.json();
            throw new Error(err.error || `HTTP ${response.status}`);
        }
        event.target.reset();
        showMessage(`Asset "${payload.assetTag}" created successfully.`);
        loadAssets();
    } catch (error) {
        showMessage(`Could not create asset: ${error.message}`, true);
    }
});

// Register Institution
document.querySelector('#institutionForm').addEventListener('submit', async (event) => {
    event.preventDefault();
    const name = document.querySelector('#instNameInput').value.trim();
    if (!name) return;

    try {
        const response = await fetch(`${apiBase}/institutions`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ name: name })
        });
        if (!response.ok) {
            const err = await response.json();
            throw new Error(err.error || `HTTP ${response.status}`);
        }
        document.querySelector('#instNameInput').value = '';
        showMessage(`Institution "${name}" registered.`);
        loadInstitutions();
    } catch (error) {
        showMessage(`Failed to register institution: ${error.message}`, true);
    }
});

// Remove Institution
document.querySelector('#removeInstBtn').addEventListener('click', async () => {
    const name = document.querySelector('#instNameInput').value.trim();
    if (!name) {
        showMessage('Please enter the name of the institution to remove.', true);
        return;
    }

    try {
        const response = await fetch(`${apiBase}/institutions/${encodeURIComponent(name)}`, {
            method: 'DELETE'
        });
        if (!response.ok) {
            const err = await response.json();
            throw new Error(err.error || `HTTP ${response.status}`);
        }
        document.querySelector('#instNameInput').value = '';
        showMessage(`Institution "${name}" removed.`);
        loadInstitutions();
    } catch (error) {
        showMessage(`Failed to remove institution: ${error.message}`, true);
    }
});

// Add Maintenance Schedule Form
document.querySelector('#scheduleForm').addEventListener('submit', async (event) => {
    event.preventDefault();
    const tag = document.querySelector('#assetTagInput').value.trim();
    const payload = {
        scheduleId: document.querySelector('#scheduleIdInput').value.trim(),
        type: 'MAINTENANCE',
        dueDate: document.querySelector('#dueDateInput').value,
        description: document.querySelector('#descriptionInput').value.trim()
    };

    try {
        const response = await fetch(`${apiBase}/assets/${encodeURIComponent(tag)}/schedules`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        event.target.reset();
        showMessage(`Maintenance schedule added to "${tag}".`);
        loadAssets();
    } catch (error) {
        showMessage(`Schedule was not added: ${error.message}`, true);
    }
});

// Book Room or Lab Space Form
document.querySelector('#bookingForm').addEventListener('submit', async (event) => {
    event.preventDefault();
    const tag = document.querySelector('#bookingAssetTagInput').value.trim();
    const payload = {
        bookingId: document.querySelector('#bookingIdInput').value.trim(),
        type: 'BOOKING',
        bookingDate: document.querySelector('#bookingDateInput').value,
        description: document.querySelector('#bookingDescriptionInput').value.trim()
    };

    try {
        const response = await fetch(`${apiBase}/assets/${encodeURIComponent(tag)}/bookings`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        if (!response.ok) {
            const err = await response.json();
            throw new Error(err.error || `HTTP ${response.status}`);
        }
        event.target.reset();
        showMessage(`Space "${tag}" booked successfully.`);
        loadAssets();
    } catch (error) {
        showMessage(`Space was not booked: ${error.message}`, true);
    }
});

// Open Work Order Form
document.querySelector('#workOrderForm').addEventListener('submit', async (event) => {
    event.preventDefault();
    const tag = document.querySelector('#woAssetTagInput').value.trim();
    const payload = {
        orderId: document.querySelector('#woOrderIdInput').value.trim(),
        status: document.querySelector('#woStatusSelect').value,
        description: document.querySelector('#woDescriptionInput').value.trim(),
        tasks: []
    };

    try {
        const response = await fetch(`${apiBase}/assets/${encodeURIComponent(tag)}/workorders`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        if (!response.ok) {
            const err = await response.json();
            throw new Error(err.error || `HTTP ${response.status}`);
        }
        event.target.reset();
        showMessage(`Work order "${payload.orderId}" opened for "${tag}".`);
    } catch (error) {
        showMessage(`Work order was not created: ${error.message}`, true);
    }
});

// Initial load
loadAssets();
loadInstitutions();

