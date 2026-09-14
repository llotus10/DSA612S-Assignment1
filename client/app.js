const apiBase = 'http://localhost:9091/api/library';
const assetGrid = document.querySelector('#assetGrid');
const message = document.querySelector('#message');

function showMessage(text) {
    message.textContent = text;
}

function renderAssets(assets) {
    assetGrid.innerHTML = '';
    if (!assets.length) {
        assetGrid.innerHTML = '<p>No assets found for this view.</p>';
        return;
    }
    assets.forEach((asset) => {
        const card = document.createElement('article');
        card.className = 'asset-card';
        card.innerHTML = `
            <div class="tag">${asset.assetTag}</div>
            <h2>${asset.name}</h2>
            <p>${asset.description || 'No description provided.'}</p>
            <p>${asset.institution}</p>
            <p>${asset.site}</p>
            <span class="status">${asset.status}</span>
            ${asset.status === 'AVAILABLE' ? `<button class="button loan-button" data-action="loan" data-tag="${asset.assetTag}">Loan asset</button>` : ''}
            ${asset.status === 'LOANED_OUT' ? `<button class="button return-button" data-action="return" data-tag="${asset.assetTag}">Return asset</button>` : ''}`;
        assetGrid.appendChild(card);
    });
}

assetGrid.addEventListener('click', async (event) => {
    const button = event.target.closest('.loan-button, .return-button');
    if (!button) return;
    button.disabled = true;
    try {
        const actionPath = button.dataset.action === 'loan' ? 'loan' : 'release';
        const response = await fetch(`${apiBase}/assets/${encodeURIComponent(button.dataset.tag)}/${actionPath}`, { method: 'PATCH' });
        if (!response.ok) throw new Error(`Request failed (${response.status})`);
        showMessage(button.dataset.action === 'loan' ? 'Asset loaned successfully.' : 'Asset returned successfully.');
        loadAssets();
    } catch (error) {
        showMessage(`Asset was not loaned: ${error.message}`);
        button.disabled = false;
    }
});

async function loadAssets(path = '/assets') {
    showMessage('Loading assets...');
    try {
        const response = await fetch(apiBase + path);
        if (!response.ok) throw new Error(`Request failed (${response.status})`);
        const assets = await response.json();
        renderAssets(assets);
        showMessage(`${assets.length} asset${assets.length === 1 ? '' : 's'} shown.`);
    } catch (error) {
        showMessage(`Could not reach the library service: ${error.message}`);
    }
}

document.querySelector('#refreshButton').addEventListener('click', () => loadAssets());
document.querySelector('#overdueButton').addEventListener('click', () => loadAssets('/assets/maintenance/overdue'));
document.querySelector('#filterButton').addEventListener('click', () => {
    const institution = document.querySelector('#institutionInput').value.trim();
    const site = document.querySelector('#siteInput').value.trim();
    if (!institution) return loadAssets();
    let path = `/assets/institution/${encodeURIComponent(institution)}`;
    if (site) path += `/site/${encodeURIComponent(site)}`;
    loadAssets(path);
});

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
        if (!response.ok) throw new Error(`Request failed (${response.status})`);
        event.target.reset();
        showMessage('Maintenance schedule added.');
        loadAssets();
    } catch (error) {
        showMessage(`Schedule was not added: ${error.message}`);
    }
});

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
        if (!response.ok) throw new Error(`Request failed (${response.status})`);
        event.target.reset();
        showMessage('Space booked successfully.');
    } catch (error) {
        showMessage(`Space was not booked: ${error.message}`);
    }
});

loadAssets();
