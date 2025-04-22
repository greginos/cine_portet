document.addEventListener('DOMContentLoaded', function() {
  const searchInput = document.querySelector('.movie-search-input');
  const resultsDiv = document.querySelector('.movie-results');
  const tmdbIdInput = document.querySelector('#programmation_tmdb_id');
  let searchTimeout;

  if (!searchInput || !resultsDiv || !tmdbIdInput) return;

  searchInput.addEventListener('input', function() {
    clearTimeout(searchTimeout);
    const query = this.value.trim();

    searchTimeout = setTimeout(() => {
      if (query.length < 2) {
        resultsDiv.innerHTML = '';
        return;
      }

      fetch(`/staff/programmations/search_movies?query=${encodeURIComponent(query)}`)
        .then(response => response.json())
        .then(movies => {
          resultsDiv.innerHTML = '';
          movies.forEach(movie => {
            const div = document.createElement('div');
            div.className = 'movie-result';
            div.innerHTML = `
              <div class="movie-title">${movie.title} (${movie.release_date?.split('-')[0] || 'N/A'})</div>
              ${movie.overview ? `<div class="movie-overview">${movie.overview.substring(0, 100)}...</div>` : ''}
            `;
            div.addEventListener('click', () => {
              searchInput.value = movie.title;
              tmdbIdInput.value = movie.id;
              resultsDiv.innerHTML = '';
            });
            resultsDiv.appendChild(div);
          });
        })
        .catch(error => {
          console.error('Erreur lors de la recherche de films:', error);
          resultsDiv.innerHTML = '<div class="error">Erreur lors de la recherche de films</div>';
        });
    }, 300);
  });
}); 