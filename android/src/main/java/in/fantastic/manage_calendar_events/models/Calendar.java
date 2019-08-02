package in.fantastic.manage_calendar_events.models;

public final class Calendar {

  private final String id;
  private final String name;
  private final String accountName;
  private final String ownerName;

  public Calendar(String id, String name, String accountName, String ownerName) {
    this.id = id;
    this.name = name;
    this.accountName = name;
    this.ownerName = name;
  }

  public String getId() {
    return id;
  }

  public String getName() {
    return name;
  }

  public String getAccountName() {
    return accountName;
  }

  public String getOwnerName() {
    return ownerName;
  }

  @Override
  public String toString() {
    return new StringBuffer().append(id).append("-").append(name).append("-").append(accountName)
        .append("-")
        .append(ownerName).toString();
  }
}
