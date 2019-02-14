import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;

//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {

        try {

            // establishes connection
            connection = DriverManager.getConnection(url, username, password);

            // sets the search path to parlgov
            String sql = "SET search_path TO parlgov;";
            PreparedStatement statement = connection.prepareStatement(sql);
            statement.execute();

            return true;

        } catch (SQLException e) {
            // e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean disconnectDB() {

        if (connection == null) {
            return true;
        }

        try {

            connection.close();
            return true;

        } catch (SQLException e) {
            // e.printStackTrace();
            return false;
        }
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {

        // elections in that country
        List<Integer> elections = new ArrayList<>();
        // cabinets formed after that election
        List<Integer> cabinets = new ArrayList<>();

        try {
            // sql prepared statement
            String sql = new StringBuilder()
                    .append("SELECT election.id, cabinet.id FROM election, country, cabinet ")
                    .append("WHERE country.name = ? ")
                    .append("AND country.id = election.country_id ")
                    .append("AND election.id = cabinet.election_id ")
                    .append("ORDER BY election.e_date DESC;")
                    .toString();
            PreparedStatement statement = connection.prepareStatement(sql);
            statement.setString(1, countryName);

            // query result
            ResultSet set = statement.executeQuery();
            while (set.next()) {
                int electionId = set.getInt(1);
                int cabinetId = set.getInt(2);
                elections.add(electionId);
                cabinets.add(cabinetId);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        ElectionCabinetResult result = new ElectionCabinetResult(elections, cabinets);
        return result;
    }

    /**
     * Get politician tokens by politician id. tokens = description + " " + comment.
     */
    private String getPoliticianTokens(Integer politicianId) {

        // politician description
        String result = null;

        try {
            // sql prepared statement
            String sql = new StringBuilder()
                    .append("SELECT description, comment FROM politician_president ")
                    .append("WHERE politician_president.id = ?;")
                    .toString();
            PreparedStatement statement = connection.prepareStatement(sql);
            statement.setInt(1, politicianId);

            // query result
            ResultSet set = statement.executeQuery();
            if (set.next()) {
                // contact description and comment with a space,
                // because tokens separate by space.
                result = set.getString(1) + " " + set.getString(2);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return result;
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {

        // politician description
        String politicianTokens = getPoliticianTokens(politicianName);

        // politician not exists
        if (politicianTokens == null) {
            return new ArrayList<>();
        }

        List<Integer> similarPoliticians = new ArrayList<>();

        try {
            // sql prepared statement
            String sql = "SELECT id, description, comment FROM politician_president;";
            PreparedStatement statement = connection.prepareStatement(sql);

            // query result
            ResultSet set = statement.executeQuery();

            while (set.next()) {
                int id = set.getInt(1);
                String description = set.getString(2);
                String comment = set.getString(3);

                // skip politician self
                if (id != politicianName) {

                    // contact description and comment with a space,
                    // because tokens separate by space.
                    String tokens = description + " " + comment;

                    double similarity = similarity(tokens, politicianTokens);

                    if (similarity >= threshold) {
                        similarPoliticians.add(id);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return similarPoliticians;
    }

    public static void main(String[] args) throws Exception {

        String url = "jdbc:postgresql://localhost/mydb";
        String username = "postgres";
        String password = "zhuzhaoyang123";

        Assignment2 a2 = new Assignment2();
        if (!a2.connectDB(url, username, password)) {
            System.out.println("connection failed.");
        }

        // test electionSequence
        String[] countries = {"Japan", "Canada", "France", "United Kingdom", "Germany"};
        for (String country : countries) {
            ElectionCabinetResult result = a2.electionSequence(country);
            System.out.println(result);
        }

        // test findSimilarPoliticians
        System.out.println(a2.findSimilarPoliticians(9, 0.1f));
        System.out.println(a2.findSimilarPoliticians(37, 0.03f));
        System.out.println(a2.findSimilarPoliticians(38, 0.28f));

        if (!a2.disconnectDB()) {
            System.out.println("disconnect failed.");
        }
    }

}

