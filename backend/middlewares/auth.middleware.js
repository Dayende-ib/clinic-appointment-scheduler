const jwt = require("jsonwebtoken");

module.exports = (roles = []) => {
  return (req, res, next) => {
    const token = req.headers.authorization?.split(" ")[1];
    if (!token) return res.status(401).json({ message: "Token manquant" });

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      if (roles.length && !roles.includes(decoded.role)) {
        return res.status(403).json({ message: "Accès interdit" });
      }

      req.user = decoded; // on ajoute l'utilisateur dans la requête
      next();

    } catch {
      return res.status(401).json({ message: "Token invalide" });
    }
  };
};
