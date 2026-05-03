---
icon: fas fa-newspaper
order: 3
hide_title: true
toc: false
---

<style>
  .coverage-intro {
    margin-bottom: 2rem;
    line-height: 1.65;
  }
  .coverage-intro p { margin-bottom: 0.85rem; }
  .coverage-intro p:last-child { margin-bottom: 0; }

  .coverage-year {
    font-size: 1.5rem;
    font-weight: 700;
    margin: 2rem 0 0.75rem;
    padding-bottom: 0.35rem;
    border-bottom: 1px solid var(--main-border-color, #e9ecef);
  }

  .coverage-entry {
    padding: 0.85rem 0;
    border-bottom: 1px solid var(--main-border-color, #f1f3f5);
  }
  .coverage-entry:last-child { border-bottom: none; }

  .coverage-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem 0.75rem;
    align-items: center;
    font-size: 0.875rem;
    margin-bottom: 0.25rem;
  }
  .coverage-outlet {
    font-weight: 700;
    color: var(--heading-color, #212529);
  }
  .coverage-date {
    color: var(--text-muted-color, #6c757d);
  }
  .coverage-affiliation {
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    padding: 0.15rem 0.5rem;
    border-radius: 0.25rem;
    background: var(--btn-backtotop-bg, #f1f3f5);
    color: var(--text-muted-color, #6c757d);
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

  .coverage-quote {
    margin: 0.4rem 0 0;
    padding: 0.25rem 0 0.25rem 0.85rem;
    border-left: 3px solid var(--main-border-color, #dee2e6);
    color: var(--text-muted-color, #495057);
    font-style: italic;
    font-size: 0.95rem;
    line-height: 1.55;
  }
</style>

<div class="coverage-intro">
<p>My work and contributions at Socket and Recorded Future have been cited, shared, and discussed across multiple security venues.</p>

<p>I’m grateful to have my research surfaced by respected security newsletters and communities, including <a href="https://risky.biz/" target="_blank" rel="noopener">Risky Biz</a>, <a href="https://tldrsec.com/" target="_blank" rel="noopener">tl;dr sec</a>, and <a href="https://www.vulnu.com/" target="_blank" rel="noopener">VulnerableU</a>. This section collects public examples of that coverage and shows how the work reaches practitioners beyond the original publication.</p>

<p>For me, this kind of visibility matters because it helps confirm that the research is useful, read by defenders, and contributing to the broader effort to protect the software supply chain and open source ecosystem from threat actors who abuse trusted technology.</p>
</div>

{% assign coverage = site.data.coverage | sort: 'date' | reverse %}
{% assign by_year = coverage | group_by_exp: "item", "item.date | date: '%Y'" %}

{% for group in by_year %}
<div class="coverage-year">{{ group.name }}</div>

{% for item in group.items %}
<div class="coverage-entry">
  <div class="coverage-meta">
    <span class="coverage-outlet">{{ item.outlet }}</span>
    <span class="coverage-date">{{ item.date | date: "%b %-d, %Y" }}</span>
    {% if item.affiliation %}<span class="coverage-affiliation">{{ item.affiliation }}</span>{% endif %}
    {% if item.topic %}<span class="coverage-topic">{{ item.topic }}</span>{% endif %}
  </div>
  <a class="coverage-headline" href="{{ item.url }}" target="_blank" rel="noopener">{{ item.headline }}</a>
  {% if item.quote %}
  <blockquote class="coverage-quote">{{ item.quote }}</blockquote>
  {% endif %}
</div>
{% endfor %}

{% endfor %}
