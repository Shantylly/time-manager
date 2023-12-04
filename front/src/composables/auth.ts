// Utilitaire de vérification du token (par exemple, dans un fichier auth.js)
export function isTokenValid() {
  // Vérifiez si le token est valide (par exemple, non expiré)
  const token = sessionStorage.getItem('token')
  return !!token // Vérification simple, vous pouvez ajouter une vérification plus détaillée si nécessaire
}
