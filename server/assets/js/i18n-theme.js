// i18n y Theme Management

class I18nManager {
  constructor() {
    this.currentLanguage = localStorage.getItem('language') || 'es';
    this.currentTheme = localStorage.getItem('theme') || 'light';
    this.translations = {};
    this.init();
  }

  async init() {
    await this.loadTranslations();
    this.applyTheme();
    this.applyLanguage();
    this.setupListeners();
  }

  async loadTranslations() {
    try {
      const enResponse = await fetch('/locales/en.json');
      const esResponse = await fetch('/locales/es.json');
      
      this.translations.en = await enResponse.json();
      this.translations.es = await esResponse.json();
    } catch (error) {
      console.error('Error loading translations:', error);
    }
  }

  setLanguage(lang) {
    if (lang === 'en' || lang === 'es') {
      this.currentLanguage = lang;
      localStorage.setItem('language', lang);
      this.applyLanguage();
      document.documentElement.lang = lang;
    }
  }

  setTheme(theme) {
    if (theme === 'light' || theme === 'dark') {
      this.currentTheme = theme;
      localStorage.setItem('theme', theme);
      this.applyTheme();
    }
  }

  toggleTheme() {
    const newTheme = this.currentTheme === 'light' ? 'dark' : 'light';
    this.setTheme(newTheme);
  }

  applyTheme() {
    document.documentElement.setAttribute('data-theme', this.currentTheme);
    const themeToggle = document.getElementById('theme-toggle');
    if (themeToggle) {
      themeToggle.textContent = this.currentTheme === 'light' ? '🌙' : '☀️';
    }
  }

  applyLanguage() {
    const elements = document.querySelectorAll('[data-i18n]');
    elements.forEach(el => {
      const key = el.getAttribute('data-i18n');
      const translation = this.getTranslation(key);
      if (translation) {
        el.textContent = translation;
      }
    });

    const attrElements = document.querySelectorAll('[data-i18n-placeholder]');
    attrElements.forEach(el => {
      const key = el.getAttribute('data-i18n-placeholder');
      const translation = this.getTranslation(key);
      if (translation) {
        el.placeholder = translation;
      }
    });
  }

  getTranslation(key) {
    const keys = key.split('.');
    let value = this.translations[this.currentLanguage];
    
    for (let k of keys) {
      if (value && typeof value === 'object') {
        value = value[k];
      } else {
        return null;
      }
    }
    
    return value;
  }

  setupListeners() {
    const languageSelect = document.getElementById('language-select');
    if (languageSelect) {
      languageSelect.value = this.currentLanguage;
      languageSelect.addEventListener('change', (e) => {
        this.setLanguage(e.target.value);
      });
    }

    const themeToggle = document.getElementById('theme-toggle');
    if (themeToggle) {
      themeToggle.addEventListener('click', () => {
        this.toggleTheme();
      });
    }
  }
}

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
  window.i18nManager = new I18nManager();
});

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = I18nManager;
}
