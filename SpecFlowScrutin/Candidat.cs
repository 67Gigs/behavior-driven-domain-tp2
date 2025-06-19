namespace SpecFlowScrutin;

public class Candidat
{
    public string Nom { get; set; }
    public int Votes { get; set; }

    public Candidat(string nom, int votes)
    {
        Nom = nom;
        Votes = votes;
    }

    public Candidat(string nom)
    {
        Nom = nom;
        Votes = 0;
    }

    public Candidat()
    {
        Nom = "";
        Votes = 0;
    }
}