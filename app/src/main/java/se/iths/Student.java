package se.iths;

import java.util.ArrayList;
import java.util.Collection;

public class Student {
    private final int studentId;
    private String firstName;
    private String lastName;
    private Collection<School> schools = new ArrayList<>();

    public Student(int studentId, String firstName, String lastName) {
        this.studentId = studentId;
        this.firstName = firstName;
        this.lastName = lastName;
    }

    public int getStudentId() {
        return studentId;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public Collection<School> getSchools() {
        return schools;
    }

    public void setSchools(Collection<School> schools) {
        this.schools = schools;
    }

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder(String.valueOf(studentId));
        builder.append(": ");
        builder.append(firstName);
        builder.append(lastName);
        builder.append("\nSchools:\n");
        for (School school : schools) {
            builder.append("\t");
            builder.append(school);
            builder.append("\n");
        }
        return builder.toString();
    }
}
