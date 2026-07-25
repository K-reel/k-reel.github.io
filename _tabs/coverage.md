---
title: Coverage
icon: fas fa-newspaper
order: 3
hide_title: true
toc: false
---

<style>
  .coverage-intro {
    margin-bottom: 2.25rem;
    line-height: 1.65;
  }
  .coverage-intro p { margin-bottom: 0.85rem; }
  .coverage-intro p:last-child { margin-bottom: 0; }

  .coverage-outlet-section {
    margin: 2.25rem 0;
  }

  .coverage-outlet-header {
    display: flex;
    align-items: center;
    gap: 0.85rem;
    margin-bottom: 0.75rem;
    padding-bottom: 0.55rem;
    border-bottom: 1px solid rgba(128, 128, 128, 0.28);
  }

  .coverage-outlet-logo {
    width: auto;
    height: 36px;
    max-width: 140px;
    object-fit: contain;
    flex-shrink: 0;
  }

  .coverage-outlet-fallback {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background: var(--btn-backtotop-bg, #e9ecef);
    color: var(--text-muted-color, #6c757d);
    font-weight: 700;
    font-size: 1rem;
    flex-shrink: 0;
  }

  .coverage-outlet-name {
    font-size: 1.35rem;
    font-weight: 700;
    margin: 0;
    color: var(--heading-color, #212529);
    border: 0;
    padding: 0;
  }

  .coverage-outlet-count {
    margin-left: auto;
    font-size: 0.78rem;
    font-weight: 500;
    color: var(--text-muted-color, #6c757d);
  }

  .coverage-entry {
    padding: 0.7rem 0;
    border-bottom: 1px solid var(--main-border-color, #f1f3f5);
  }
  .coverage-entry:last-child { border-bottom: none; }

  .coverage-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem 0.75rem;
    align-items: center;
    font-size: 0.85rem;
    margin-bottom: 0.2rem;
  }
  .coverage-date {
    color: var(--text-muted-color, #6c757d);
  }
  a.coverage-source,
  a.coverage-source:link,
  a.coverage-source:visited {
    font-size: 0.7rem;
    font-weight: 600;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    padding: 0.12rem 0.5rem;
    border-radius: 0.25rem;
    background: #121212;
    color: #1971c2;
    border: 1px solid #1971c2;
    text-decoration: none;
    transition: background 0.15s, color 0.15s;
  }
  a.coverage-source:hover,
  a.coverage-source:focus,
  a.coverage-source:active {
    background: #ffffff;
    color: #1971c2;
    text-decoration: none;
  }
  .coverage-topic {
    font-size: 0.78rem;
    color: var(--text-muted-color, #6c757d);
  }
  .coverage-topic::before { content: "·"; margin-right: 0.5rem; }

  .coverage-headline {
    display: block;
    font-size: 1.05rem;
    line-height: 1.4;
    margin: 0.15rem 0 0.4rem;
  }
  .content a.coverage-headline,
  .content a.coverage-headline:link,
  .content a.coverage-headline:visited {
    color: var(--heading-color, #212529);
    text-decoration: none;
    border-bottom: 1px solid rgba(128, 128, 128, 0.45);
  }

  .coverage-quote {
    margin: 0.4rem 0 0;
    padding: 0.25rem 0 0.25rem 0.85rem;
    border-left: 3px solid var(--main-border-color, #dee2e6);
    color: var(--text-muted-color, #495057);
    font-style: italic;
    font-size: 0.95rem;
    line-height: 1.55;
  }

  /* Collapsible outlet sections */
  details.coverage-outlet-section > summary {
    list-style: none;
    cursor: pointer;
  }
  details.coverage-outlet-section > summary::-webkit-details-marker {
    display: none;
  }
  details.coverage-outlet-section > summary:hover .coverage-outlet-name {
    color: var(--link-color, #1d6fbb);
  }
  .coverage-outlet-chevron {
    margin-left: 0.85rem;
    font-size: 1.15rem;
    line-height: 1;
    color: var(--text-muted-color, #6c757d);
    transition: transform 0.2s ease;
    flex-shrink: 0;
  }
  details.coverage-outlet-section[open] > summary .coverage-outlet-chevron {
    transform: rotate(90deg);
  }

  #toggle-all {
    border: none;
    background: #fff;
    color: #000;
    padding: 0.45rem 1.1rem;
    border-radius: 0.5rem;
    cursor: pointer;
    font-size: 0.9rem;
    font-weight: 600;
    margin-bottom: 0.75rem;
    letter-spacing: 0.02em;
    transition: opacity 0.2s;
  }
  #toggle-all:hover {
    opacity: 0.85;
  }

  /* Coverage banner — full-width, sits tight above the intro text */
  .coverage-banner {
    margin: 0 0 0.9rem;
  }
  @media (min-width: 850px) {
    /* bleed to the content-panel edges (reclaim the theme's side padding) */
    .coverage-banner {
      margin-left: -1.75rem;
      margin-right: -1.75rem;
    }
  }
  /* force full width even through the theme's lightbox wrapper */
  .coverage-banner a.popup,
  .coverage-banner .img-link,
  .coverage-banner img {
    display: block !important;
    width: 100% !important;
    max-width: none !important;
    left: auto !important;
    transform: none !important;
    margin-inline: 0 !important;
  }
  .coverage-banner img {
    height: auto !important;
    aspect-ratio: auto !important;
    object-fit: contain !important;
    border-radius: 12px;
    box-shadow: 0 6px 18px rgba(0, 0, 0, 0.30);
  }
</style>

<div class="coverage-banner" markdown="1">
![Coverage banner](/assets/img/coverage/banner.png){: w="2400" }
</div>

<div class="coverage-intro">
<p>My work and contributions at Socket and Recorded Future have been cited, shared, and discussed across multiple security venues. I’m grateful to have my research surfaced by respected security publications, newsletters, and communities, including The Hacker News, Risky Biz, Detection Engineering Weekly, tl;dr sec, and VulnerableU. It has also been cited in the MITRE ATT&amp;CK knowledge base. This section collects public examples of that coverage and shows how the work reaches practitioners beyond the original publication. This kind of visibility helps confirm that the research is useful, read by defenders, and contributing to the broader effort to protect our community from threat actors who seek to abuse the systems and technologies we trust.</p>
</div>

<button id="toggle-all" onclick="(function(){
  var details = document.querySelectorAll('.content details');
  var anyOpen = Array.from(details).some(function(d){ return d.open; });
  details.forEach(function(d){ d.open = !anyOpen; });
  document.getElementById('toggle-all').textContent = anyOpen ? 'Expand All' : 'Collapse All';
})()">Expand All</button>

{% assign coverage = site.data.coverage | sort: 'date' | reverse %}
{% assign outlets = "" | split: "," %}
{% for item in coverage %}
  {% unless outlets contains item.outlet %}
    {% assign outlets = outlets | push: item.outlet %}
  {% endunless %}
{% endfor %}

{% for outlet in outlets %}
  {% assign outlet_entries = coverage | where: "outlet", outlet %}
  {% assign outlet_meta = site.data.coverage_outlets[outlet] %}
  {% assign count = outlet_entries | size %}

  <details class="coverage-outlet-section">
    <summary class="coverage-outlet-header">
      {% if outlet_meta and outlet_meta.logo %}
        <img src="{{ outlet_meta.logo }}" alt="{{ outlet }} logo" class="coverage-outlet-logo"
             onerror="this.style.display='none'; this.nextElementSibling.style.display='inline-flex';" />
        <span class="coverage-outlet-fallback" style="display:none;">{{ outlet | slice: 0, 1 }}</span>
      {% else %}
        <span class="coverage-outlet-fallback">{{ outlet | slice: 0, 1 }}</span>
      {% endif %}
      {% unless outlet_meta.hide_name %}
      <h2 class="coverage-outlet-name">{{ outlet }}</h2>
      {% endunless %}
      <span class="coverage-outlet-count">{{ count }} {% if count == 1 %}article{% else %}articles{% endif %}</span>
      <span class="coverage-outlet-chevron" aria-hidden="true">&rsaquo;</span>
    </summary>

    {% for item in outlet_entries %}
    <div class="coverage-entry">
      <div class="coverage-meta">
        <span class="coverage-date">{{ item.date | date: "%b %-d, %Y" }}</span>
        {% if item.source_url %}<a class="coverage-source" href="{{ item.source_url }}">Source</a>{% endif %}
        {% if item.topic %}{% assign topic_list = item.topic | split: "," %}{% for topic in topic_list %}<span class="coverage-topic">{{ topic | strip }}</span>{% endfor %}{% endif %}
      </div>
      <a class="coverage-headline" href="{{ item.url }}" target="_blank" rel="noopener">{{ item.headline }}</a>
      {% if item.quote %}
      <blockquote class="coverage-quote">{{ item.quote }}</blockquote>
      {% endif %}
    </div>
    {% endfor %}
  </details>
{% endfor %}
