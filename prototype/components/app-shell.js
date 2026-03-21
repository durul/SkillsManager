// ===== APP SHELL: Sidebar + Layout wrapper =====
// Reusable across all pages. Each page only provides main content.

function renderSidebar({ activeNav = 'all-installed' } = {}) {
  return `
  <aside class="sidebar">
    <div class="sidebar-header">
      <h1>${Icons.book} Skills Manager</h1>
    </div>
    <div class="search-box">
      ${Icons.search}
      <input type="text" placeholder="Search skills..." />
    </div>
    <div class="source-sections">
      <div class="source-section">
        <div class="source-header"><span>Installed</span><span class="count">12</span></div>
        <div class="nav-item${activeNav === 'all-installed' ? ' active' : ''}" data-nav="all-installed" onclick="setActiveNav(this)">
          ${Icons.folder} All Installed <span class="badge installed">12</span>
        </div>
        <div class="nav-item${activeNav === 'claude' ? ' active' : ''}" data-nav="claude" onclick="setActiveNav(this)">
          ${Icons.cube} Claude Code <span class="badge installed">10</span>
        </div>
        <div class="nav-item${activeNav === 'codex' ? ' active' : ''}" data-nav="codex" onclick="setActiveNav(this)">
          ${Icons.grid} Codex <span class="badge installed">8</span>
        </div>
      </div>
      <div class="source-section">
        <div class="source-header"><span>Catalogs</span><span class="count">3</span></div>
        <div class="nav-item${activeNav === 'anthropic' ? ' active' : ''}" data-nav="anthropic" onclick="setActiveNav(this)">
          ${Icons.github} Anthropic Skills <span class="badge">24</span>
        </div>
        <div class="nav-item${activeNav === 'team' ? ' active' : ''}" data-nav="team" onclick="setActiveNav(this)">
          ${Icons.github} My Team Skills <span class="badge">9</span>
        </div>
        <div class="nav-item${activeNav === 'local-dir' ? ' active' : ''}" data-nav="local-dir" onclick="setActiveNav(this)">
          ${Icons.folder} ~/projects/skills <span class="badge">5</span>
        </div>
      </div>
    </div>
    <div class="sidebar-footer">
      <button class="btn-add-catalog" onclick="showModal('modal-add-catalog')">
        ${Icons.plus} Add Catalog
      </button>
    </div>
  </aside>`;
}

function renderAddCatalogModal() {
  return `
  <div class="modal-overlay hidden" id="modal-add-catalog" onclick="if(event.target===this)hideModal('modal-add-catalog')">
    <div class="modal">
      <div class="modal-header">
        <h2>Add Skill Catalog</h2>
        <p>Import skills from a GitHub repository or local directory</p>
      </div>
      <div class="modal-body">
        <div class="source-option selected" onclick="selectSourceOption(this)">
          <div class="source-option-header">
            <div class="source-option-icon github">${Icons.github}</div>
            <div><div class="source-option-title">GitHub Repository</div></div>
          </div>
          <div class="source-option-desc">Clone a GitHub repository containing skills. The repo will be cached locally for offline access.</div>
          <div class="source-option-input">
            <input type="text" placeholder="https://github.com/org/skills-repo" />
          </div>
        </div>
        <div class="source-option" onclick="selectSourceOption(this)">
          <div class="source-option-header">
            <div class="source-option-icon folder">${Icons.folder}</div>
            <div><div class="source-option-title">Local Directory</div></div>
          </div>
          <div class="source-option-desc">Add skills from a local folder. Each subfolder with a SKILL.md file will be recognized as a skill.</div>
          <div class="source-option-input" style="display:flex;gap:8px;">
            <input type="text" placeholder="~/projects/my-skills" style="flex:1;" />
            <button class="btn btn-secondary" style="white-space:nowrap;">Browse</button>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" onclick="hideModal('modal-add-catalog')">Cancel</button>
        <button class="btn btn-primary">Add Catalog</button>
      </div>
    </div>
  </div>`;
}

// ===== PAGE NAV (prototype navigation) =====
function renderPageNav(activePage) {
  const pages = [
    { id: 'browse', label: 'Browse', file: 'index.html' },
    { id: 'editor', label: 'Editor', file: 'pages/editor.html' },
    { id: 'install', label: 'Install', file: 'pages/install.html' },
  ];
  const btns = pages.map(p => {
    const isActive = p.id === activePage;
    const style = isActive
      ? 'background:var(--accent);color:white;border:none;'
      : 'background:var(--bg-card);color:var(--text-secondary);border:1px solid var(--border);';
    return `<a href="${p.id === 'browse' ? '../index.html' : (activePage === 'browse' ? 'pages/' + p.file.replace('pages/','') : p.file.replace('pages/',''))}" style="${style}padding:6px 14px;border-radius:20px;font-size:12px;cursor:pointer;font-family:var(--font-sans);text-decoration:none;">${p.label}</a>`;
  }).join('');
  return `<div style="position:fixed;bottom:16px;left:50%;transform:translateX(-50%);display:flex;gap:8px;z-index:200;background:var(--bg-secondary);padding:6px 10px;border-radius:24px;border:1px solid var(--border);box-shadow:0 4px 24px rgba(0,0,0,0.4);">${btns}</div>`;
}

// ===== SHARED INTERACTIONS =====
function setActiveNav(el) {
  document.querySelectorAll('.nav-item').forEach(i => i.classList.remove('active'));
  el.classList.add('active');
}

function showModal(id) {
  document.getElementById(id)?.classList.remove('hidden');
}

function hideModal(id) {
  document.getElementById(id)?.classList.add('hidden');
}

function selectSourceOption(el) {
  document.querySelectorAll('.source-option').forEach(o => o.classList.remove('selected'));
  el.classList.add('selected');
}

function selectCard(el) {
  document.querySelectorAll('.skill-card').forEach(c => c.classList.remove('selected'));
  el.classList.add('selected');
}

function selectTab(el) {
  el.parentElement.querySelectorAll('.category-tab').forEach(t => t.classList.remove('active'));
  el.classList.add('active');
}
