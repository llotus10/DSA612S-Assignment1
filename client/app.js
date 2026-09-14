const apiBase = 'http://localhost:9090/api/library';
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
            <span class="status">${asset.status}</span>`;
        assetGrid.appendChild(card);
    });
}

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

loadAssets();
