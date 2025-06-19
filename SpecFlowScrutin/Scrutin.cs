namespace SpecFlowScrutin;

public class Scrutin
{
    private Dictionary<string, int> _votes;
    private List<string> _candidats;
    private List<string> _candidatsQualifies;
    private bool _estCloture;
    private int _tourActuel;
    private int _votesBlancs;

    public bool EstCloture => _estCloture;
    public int TourActuel => _tourActuel;
    public int VotesBlancs => _votesBlancs;

    public Scrutin()
    {
        _votes = new Dictionary<string, int>();
        _candidats = new List<string>();
        _candidatsQualifies = new List<string>();
        _estCloture = false;
        _tourActuel = 1;
        _votesBlancs = 0;
    }

    public void AjouterCandidat(string nom)
    {
        if (!_candidats.Contains(nom))
        {
            _candidats.Add(nom);
            _votes[nom] = 0;
        }
    }

    public void DefinirTour(int tour)
    {
        if (tour < 1 || tour > 2)
            throw new ArgumentException("Le tour doit être 1 ou 2");
        
        _tourActuel = tour;
    }

    public void EnregistrerVotes(string candidat, int votes)
    {
        if (_estCloture)
            throw new InvalidOperationException("Le scrutin est déjà clôturé");

        if (!_candidats.Contains(candidat))
            throw new ArgumentException($"Le candidat {candidat} n'existe pas");

        _votes[candidat] = votes;
    }

    public void EnregistrerVotesBlancs(int votesBlancs)
    {
        if (_estCloture)
            throw new InvalidOperationException("Le scrutin est déjà clôturé");

        _votesBlancs = votesBlancs;
    }

    public void DefinirCandidatsQualifies(List<string> candidats)
    {
        _candidatsQualifies = candidats.ToList();
        
        // Pour le second tour, on ne garde que les candidats qualifiés
        if (_tourActuel == 2)
        {
            var nouveauxVotes = new Dictionary<string, int>();
            foreach (var candidat in candidats)
            {
                nouveauxVotes[candidat] = _votes.ContainsKey(candidat) ? _votes[candidat] : 0;
            }
            _votes = nouveauxVotes;
        }
    }

    public ResultatScrutin CloturerEtCalculerResultat()
    {
        _estCloture = true;
        return CalculerResultat();
    }

    public ResultatScrutin CalculerResultatSansCloturer()
    {
        if (!_estCloture)
            throw new InvalidOperationException("Le scrutin doit être clôturé pour calculer le résultat");
        
        return CalculerResultat();
    }

    private ResultatScrutin CalculerResultat()
    {
        var resultat = new ResultatScrutin();
        var totalVotesValides = _votes.Values.Sum();
        var totalVotesExprimes = totalVotesValides + _votesBlancs;

        if (totalVotesExprimes == 0)
        {
            resultat.Message = "Aucun vote enregistré";
            return resultat;
        }

        // Calculer les résultats par candidat
        var resultatsParCandidat = new List<ResultatCandidat>();
        
        foreach (var vote in _votes.OrderByDescending(v => v.Value))
        {
            var pourcentage = totalVotesValides > 0 ? Math.Round((decimal)vote.Value / totalVotesValides * 100, 2) : 0;
            resultatsParCandidat.Add(new ResultatCandidat
            {
                Candidat = vote.Key,
                Votes = vote.Value,
                Pourcentage = pourcentage
            });
        }

        resultat.ResultatsParCandidat = resultatsParCandidat;
        resultat.VotesBlancs = _votesBlancs;
        resultat.TotalVotesExprimes = totalVotesExprimes;

        // Logique de détermination du vainqueur
        var meilleurCandidat = resultatsParCandidat.FirstOrDefault();
        
        if (_tourActuel == 1)
        {
            // Premier tour : il faut plus de 50%
            if (meilleurCandidat != null && meilleurCandidat.Pourcentage > 50)
            {
                resultat.Vainqueur = meilleurCandidat.Candidat;
            }
            else
            {
                // Second tour nécessaire - garder les 2 meilleurs
                // En cas d'égalité, on prend par ordre alphabétique
                var candidatsOrdonnes = resultatsParCandidat
                    .GroupBy(r => r.Votes)
                    .OrderByDescending(g => g.Key)
                    .SelectMany(g => g.OrderBy(r => r.Candidat))
                    .Take(2)
                    .Select(r => r.Candidat)
                    .ToList();

                resultat.CandidatsQualifiesSecondTour = candidatsOrdonnes;
            }
        }
        else if (_tourActuel == 2)
        {
            // Second tour : le candidat avec le plus de voix gagne
            var deuxiemeCandidat = resultatsParCandidat.Skip(1).FirstOrDefault();
            
            if (meilleurCandidat != null && deuxiemeCandidat != null)
            {
                if (meilleurCandidat.Pourcentage == deuxiemeCandidat.Pourcentage)
                {
                    resultat.Message = "Égalité - Aucun vainqueur déterminé";
                }
                else
                {
                    resultat.Vainqueur = meilleurCandidat.Candidat;
                }
            }
            else if (meilleurCandidat != null)
            {
                resultat.Vainqueur = meilleurCandidat.Candidat;
            }
        }

        return resultat;
    }
}

public class ResultatScrutin
{
    public string Vainqueur { get; set; }
    public List<ResultatCandidat> ResultatsParCandidat { get; set; }
    public List<string> CandidatsQualifiesSecondTour { get; set; }
    public string Message { get; set; }
    public int VotesBlancs { get; set; }
    public int TotalVotesExprimes { get; set; }

    public ResultatScrutin()
    {
        ResultatsParCandidat = new List<ResultatCandidat>();
        CandidatsQualifiesSecondTour = new List<string>();
    }
}

public class ResultatCandidat
{
    public string Candidat { get; set; }
    public int Votes { get; set; }
    public decimal Pourcentage { get; set; }
}