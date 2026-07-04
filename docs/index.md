---
layout: default
---

<p class="header">
    <img src="/images/icon_128x128.png"
        srcset="/images/icon_128x128.png, /images/icon_128x128@2x.png 2x"
        width="128"
        height="128" />
    <div class="appname">{{ site.title }}</div>
    <div class="tagline">{{ site.description }}</div>
    <div class="actions">
        <a class="button no-rewrite" href="{{ site.env.DOWNLOAD_URL }}">Download</a>
    </div>
</p>

<div class="showcase">
    <div class="content">
        {% include picture.html light="/images/screenshot-default@2x.png" dark="/images/screenshot-default-dark@2x.png" %}
    </div>
</div>

<div class="content">
    <ul class="features">
        <li>
            <p><img class="symbol" src="/images/lightspectrum.horizontal.svg" /></p>
            <p><strong>Unlock Your IntelliMouse</strong></p>
            <p>Fully customize the taillight of your IntelliMouse Pro without needing Windows.</p>
        </li>
        <li>
            <p><img class="symbol" src="/images/menubar.arrow.up.rectangle.svg" /></p>
            <p><strong>Menu Bar Control</strong></p>
            <p>Change your Pro IntelliMouse's tail light color right from the menu bar.</p>
        </li>
        <li>
            <p><img class="symbol" src="/images/autostartstop.svg" /></p>
            <p><strong>Launch at Login</strong></p>
            <p>TailLight starts automatically so your mouse is always lit the way you like it.</p>
        </li>
        <li>
            <p><img class="symbol" src="/images/chevron.left.forwardslash.chevron.right.svg" /></p>
            <p><strong>Open Source</strong></p>
            <p>Developed in the open on <a href="https://github.com/inseven/taillight">GitHub</a> under the <a href="/license">MIT License</a>.</p>
        </li>
    </ul>
</div>

<div class="preview-video">
    <video autoplay muted loop playsinline>
        <source src="/images/preview.mp4" type="video/mp4">
    </video>
</div>
