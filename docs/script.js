// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
  anchor.addEventListener("click", function (e) {
    e.preventDefault();
    const target = document.querySelector(this.getAttribute("href"));
    if (target) {
      target.scrollIntoView({
        behavior: "smooth",
        block: "start",
      });
    }
  });
});

// Update download links with latest release
async function updateDownloadLinks() {
  try {
    const response = await fetch(
      "https://api.github.com/repos/yourusername/research-workspace/releases/latest"
    );
    const data = await response.json();

    // Update version displays if needed
    console.log("Latest version:", data.tag_name);
  } catch (error) {
    console.error("Failed to fetch latest release:", error);
  }
}

// Call on page load
updateDownloadLinks();
