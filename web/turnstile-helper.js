(function () {
  function ensureTurnstile() {
    if (typeof window.turnstile !== 'undefined') {
      return Promise.resolve();
    }
    return new Promise(function (resolve, reject) {
      var attempts = 0;
      var timer = setInterval(function () {
        attempts++;
        if (typeof window.turnstile !== 'undefined') {
          clearInterval(timer);
          resolve();
        } else if (attempts > 100) {
          clearInterval(timer);
          reject(new Error('Turnstile failed to load'));
        }
      }, 100);
    });
  }

  function isRetryableError(code) {
    if (typeof code !== 'string') return true;
    // 600*   = generic challenge failure / bot behavior (retryable)
    // 200100 = clock/cache problem (retryable)
    // 200500 = iframe load error (retryable)
    // 110600 = challenge timed out (retryable)
    // 110620 = interaction timed out (retryable)
    if (/^(600|200100|200500|110600|110620)/.test(code)) return true;
    return false;
  }

  function safeRemove(widgetId, container) {
    try {
      if (widgetId != null && typeof window.turnstile !== 'undefined' && typeof window.turnstile.remove === 'function') {
        window.turnstile.remove(widgetId);
      }
    } catch (_) {
      // Ignore "Nothing to reset found" and similar cleanup errors.
    }
    try {
      if (container && container.parentNode) {
        container.parentNode.removeChild(container);
      }
    } catch (_) {
      // Ignore DOM cleanup errors.
    }
  }

  function requestTokenOnce(siteKey) {
    return new Promise(function (resolve, reject) {
      var container = document.createElement('div');
      container.style.position = 'absolute';
      container.style.width = '0';
      container.style.height = '0';
      container.style.overflow = 'hidden';
      document.body.appendChild(container);

      var widgetId = null;
      var settled = false;

      function finish(value, isError) {
        if (settled) return;
        settled = true;
        safeRemove(widgetId, container);
        if (isError) {
          reject(value);
        } else {
          resolve(value);
        }
      }

      try {
        widgetId = window.turnstile.render(container, {
          sitekey: siteKey,
          size: 'compact',
          action: 'contact-submit',
          callback: function (token) {
            finish(token, false);
          },
          'error-callback': function (code) {
            finish(new Error('Turnstile error: ' + code), true);
          },
          'expired-callback': function () {
            finish(new Error('Turnstile challenge expired'), true);
          },
        });
      } catch (e) {
        finish(e, true);
      }
    });
  }

  window.requestContactTurnstileToken = async function (siteKey) {
    await ensureTurnstile();

    try {
      return await requestTokenOnce(siteKey);
    } catch (e) {
      var code = (e && e.message) || '';
      if (isRetryableError(code)) {
        // Wait briefly, then retry once.
        await new Promise(function (resolve) { setTimeout(resolve, 500); });
        return await requestTokenOnce(siteKey);
      }
      throw e;
    }
  };
})();
