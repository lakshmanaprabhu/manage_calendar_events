package com.fantastic.manage_calendar_events.models;
import com.google.gson.annotations.SerializedName;

public final class Calendar {

  @SerializedName("id")
  private final String id;
  @SerializedName("name")
  private final String name;
  @SerializedName("accountName")
  private final String accountName;
  @SerializedName("ownerName")
  private final String ownerName;
  @SerializedName("isReadOnly")
  private final boolean isReadOnly;
  @SerializedName("isLocal")
  private final boolean isLocal;

  public Calendar(String id, String name, String accountName, String ownerName,
      boolean isReadOnly, boolean isLocal) {
    this.id = id;
    this.name = name;
    this.accountName = accountName;
    this.ownerName = ownerName;
    this.isReadOnly = isReadOnly;
    this.isLocal = isLocal;
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

  public boolean isReadOnly() {
    return isReadOnly;
  }

  public boolean isLocal() {
    return isLocal;
  }

  @Override
  public String toString() {
    return new StringBuffer().append(id).append("-").append(name).append("-").append(accountName)
        .append("-")
        .append(ownerName).toString();
  }
}
