document.addEventListener('DOMContentLoaded', function() {
  const searchInput = document.getElementById('movie-search-input');
  const searchResults = document.getElementById('movie-search-results');
  const imdbIdInput = document.getElementById('programmation_imdb_id');

  if (!searchInput || !searchResults || !imdbIdInput) return;

  let searchTimeout;

  searchInput.addEventListener('input', function() {
    clearTimeout(searchTimeout);
    const query = this.value;

    if (query.length < 2) {
      searchResults.innerHTML = '';
      return;
    }

    searchTimeout = setTimeout(() => {
      fetch(`/admin/programmations/${window.location.pathname.split('/').pop()}/search_movie?query=${encodeURIComponent(query)}`)
        .then(response => response.json())
        .then(data => {
          searchResults.innerHTML = '';
          if (data.length === 0) {
            searchResults.innerHTML = '<p>Aucun résultat trouvé</p>';
            return;
          }

          const ul = document.createElement('ul');
          ul.className = 'movie-search-results-list';

          data.forEach(movie => {
            const li = document.createElement('li');
            li.className = 'movie-search-result-item';
            
            const title = movie.title || movie.name;
            const year = movie.release_date ? new Date(movie.release_date).getFullYear() : '';
            
            li.innerHTML = `
              <div class="movie-info">
                <strong>${title}</strong>
                ${year ? ` (${year})` : ''}
              </div>
            `;

            li.addEventListener('click', () => {
              imdbIdInput.value = movie.imdb_id;
              searchResults.innerHTML = '';
              searchInput.value = '';
            });

            ul.appendChild(li);
          });

          searchResults.appendChild(ul);
        })
        .catch(error => {
          console.error('Erreur lors de la recherche:', error);
          searchResults.innerHTML = '<p>Une erreur est survenue lors de la recherche</p>';
        });
    }, 300);
  });
}); 