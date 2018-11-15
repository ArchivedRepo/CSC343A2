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
            connection = DriverManager.getConnection(url, username, password);
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean disconnectDB() {
        try {
            connection.close();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        ArrayList<Integer> elections = new ArrayList<>();
        ArrayList<Integer> cabinets = new ArrayList<>();
        String query = "SELECT election_id, cabinet.id " +
                    "FROM Parlgov.Country, Parlgov.Cabinet " +
                    "WHERE cabinet.country_id = Country.id AND country.name = ? ORDER BY start_Date DESC";
        try {
            PreparedStatement statement = connection.prepareStatement(query);
            statement.setString(1, countryName);
            ResultSet result = statement.executeQuery();
            while (result.next()) {
                int thisElection = result.getInt(1);
                int thisCabinets = result.getInt(2);
                if (!elections.contains(thisElection)) {
                    elections.add(thisElection);
                }
                if (!cabinets.contains(thisCabinets)) {
                    cabinets.add(thisCabinets);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return new ElectionCabinetResult(elections, cabinets);
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        ArrayList<Integer> result = new ArrayList<>();
        String thisComment = "";
        String compare;
        String candidate = "SELECT id, description, comment " +
                "FROM Parlgov.Politician_president WHERE id = ? ";
        try {
            PreparedStatement statement = connection.prepareStatement(candidate);
            statement.setInt(1, politicianName);
            ResultSet rs = statement.executeQuery();
            while (rs.next()) {
                thisComment = rs.getString(2) + rs.getString(3);
            }
            String others = "SELECT id, description, comment FROM Parlgov.politician_president WHERE id <> ?";
            PreparedStatement statement2 = connection.prepareStatement(others);
            statement2.setInt(1, politicianName);
            ResultSet rs2 = statement2.executeQuery();
            while (rs2.next()) {
                compare = rs2.getString(2) + rs2.getString(3);
                if (similarity(thisComment, compare) >= threshold) {
                    result.add(rs2.getInt(1));
                }
            }return result;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public static void main(String[] args) throws Exception {
        // You can put testing code in here. It will not affect our autotester.
        Assignment2 a2 = new Assignment2();
        a2.connectDB("jdbc:postgresql:will", "will", "");
        System.out.println(a2.findSimilarPoliticians(304, Float.valueOf("0.25")));
    }

}

